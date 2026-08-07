/-
# The Máčajová–Škoviera transfer: finite ⟺ infinite

`InfiniteCubicMatchingsCompactness.lean` proves that the Berge–Fulkerson and the Fan–Raspaud
conjectures transfer from finite graphs to locally finite infinite graphs admitting *finite
local models*, and `InfiniteCubicMatchingsEquivalence.lean` turns those transfers into
equivalences.  The Máčajová–Škoviera conjecture was left out, because its defining condition
quantifies over **odd cuts**, i.e. over finite vertex sets, and a local isomorphism
`φ : V → W` onto a finite model need not preserve the *cardinality* of such a set: `φ` can
collapse an odd set to an even one, destroying the parity that the conjecture is about.
(This was Conjecture 4 of `FUTURE_DIRECTIONS.md`.)

This file closes that gap.  Only one extra requirement is needed: the local model must be
*faithful* on the finite window, i.e. `φ` must be injective there.  Then the image of an odd
vertex set is again odd, and the odd-cut condition pulls back.

Main results:

* `exists_msCond_of_localIso` : pullback of a Máčajová–Škoviera pair along a local
  isomorphism, including the odd-cut half of the condition on every window on which the
  local isomorphism is injective;
* `macajovaSkoviera_of_injective_finite_local_models` : the finite Máčajová–Škoviera
  conjecture implies the infinite one on the class `HasInjectiveFiniteLocalModels`;
* `finiteMacajovaSkoviera_iff` : the two conjectures are *equivalent* on that class;
* `multiCopies` and `hasInjectiveFiniteLocalModels_multiCopies` : the class is not a
  disguised finiteness assumption — the infinite graph `multiCopies ℕ K` (infinitely many
  disjoint copies of a finite cubic bridgeless graph `K`) is cubic, bridgeless, has an
  infinite vertex set, and belongs to it.
-/
import Bridges.InfiniteCubicMatchingsEquivalence
import Bridges.InfiniteCubicMatchingsBridged

namespace Bridges.InfiniteCubicMatchings

universe u v

variable {V : Type u} {W : Type v} {G : SimpleGraph V}

/-! ## Faithful finite local models -/

/-- The Máčajová–Škoviera conjecture for *finite* cubic bridgeless graphs. -/
def FiniteMacajovaSkovieraConjecture : Prop :=
  ∀ (W : Type) (_ : Fintype W) (K : SimpleGraph W), IsCubic K → Bridgeless K →
    MacajovaSkoviera K

/-- `G` *has injective (faithful) finite local models* if around every finite set `T` of
vertices it is locally isomorphic to a finite cubic bridgeless graph **by a map that is
injective on `T`**.  Injectivity is what makes odd vertex sets stay odd in the model, and it
is exactly what the Máčajová–Škoviera transfer needs on top of `HasFiniteLocalModels`. -/
def HasInjectiveFiniteLocalModels (G : SimpleGraph V) : Prop :=
  ∀ T : Finset V, ∃ (W : Type) (_ : Fintype W) (K : SimpleGraph W) (φ : V → W),
    IsCubic K ∧ Bridgeless K ∧ (∀ v ∈ T, IsLocalIsoAt G K φ v) ∧ Set.InjOn φ ↑T

theorem HasInjectiveFiniteLocalModels.hasFiniteLocalModels
    (h : HasInjectiveFiniteLocalModels G) : HasFiniteLocalModels G := by
  intro T
  obtain ⟨W, hW, K, φ, hc, hb, hiso, -⟩ := h T
  exact ⟨W, hW, K, φ, hc, hb, hiso⟩

/-- A finite cubic bridgeless graph is its own faithful local model. -/
theorem hasInjectiveFiniteLocalModels_self {W : Type} [Fintype W] (K : SimpleGraph W)
    (hc : IsCubic K) (hb : Bridgeless K) : HasInjectiveFiniteLocalModels K :=
  fun _ => ⟨W, inferInstance, K, id, hc, hb, fun v _ => isLocalIsoAt_id K v, Set.injOn_id _⟩

/-! ## Pullback of a Máčajová–Škoviera pair -/

/-- **Pullback of a Máčajová–Škoviera pair along a local isomorphism.**  If `φ` is a local
isomorphism at every `P`-vertex and `M 0, M 1` is a Máčajová–Škoviera pair of the model `K`,
then the pulled-back configuration is involutive at every `P`-vertex whose neighbours are
`P`-vertices, and refutes the odd-cut condition for every odd `P`-window on which `φ` is
injective. -/
theorem exists_msCond_of_localIso {K : SimpleGraph W} (φ : V → W) (M : Fin 2 → PerfectMatching K)
    (hM : ∀ C, IsOddCut K C → ¬ C ⊆ (M 0).edges ∩ (M 1).edges)
    (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (P : V → Prop) (hP : ∀ v, P v → IsLocalIsoAt G K φ v) :
    ∃ c : MConfig G 2,
      (∀ v, P v → (∀ x, G.Adj v x → P x) → InvolCond G c v) ∧
      (∀ S : Finset V, (∀ u ∈ S, P u) → Set.InjOn φ ↑S → Odd S.card →
        ∃ u ∈ S, ∃ w, G.Adj u w ∧ w ∉ S ∧ ¬ ((c u 0 : V) = w ∧ (c u 1 : V) = w)) := by
  classical
  have key : ∀ v : V, ∀ i : Fin 2, ∃ x : V, G.Adj v x ∧ (P v → φ x = (M i).partner (φ v)) := by
    intro v i
    by_cases h : P v
    · obtain ⟨x, hx, hxe⟩ := (hP v h).surj ((M i).partner (φ v)) ((M i).isAdj (φ v))
      exact ⟨x, hx, fun _ => hxe⟩
    · obtain ⟨x, hx⟩ := hne v
      exact ⟨x, hx, fun h' => absurd h' h⟩
  choose x hadj hphi using key
  refine ⟨fun v i => ⟨x v i, hadj v i⟩, ?_, ?_⟩
  · intro v hv hvn i
    have h1 : φ (x v i) = (M i).partner (φ v) := hphi v i hv
    have hPw : P (x v i) := hvn _ (hadj v i)
    have h2 : φ (x (x v i) i) = (M i).partner (φ (x v i)) := hphi _ i hPw
    rw [h1, (M i).invol] at h2
    exact (hP _ hPw).inj _ _ (hadj (x v i) i) (hadj v i).symm h2
  · intro S hSP hinj hodd
    have hcard : (S.image φ).card = S.card := Finset.card_image_of_injOn hinj
    have hodd' : Odd (S.image φ).card := by rw [hcard]; exact hodd
    have hnot := hM (cutEdges K (S.image φ)) ⟨S.image φ, hodd', rfl⟩
    rw [Set.not_subset] at hnot
    obtain ⟨e, heC, heM⟩ := hnot
    obtain ⟨hEe, a, b, rfl, haS, hbS⟩ := heC
    obtain ⟨u, huS, rfl⟩ := Finset.mem_image.mp haS
    have hPu : P u := hSP u huS
    obtain ⟨w, hwadj, hwb⟩ := (hP u hPu).surj b (by simpa using hEe)
    subst hwb
    refine ⟨u, huS, w, hwadj, ?_, ?_⟩
    · intro hwS
      exact hbS (Finset.mem_image_of_mem φ hwS)
    · rintro ⟨h0, h1⟩
      refine heM ⟨?_, ?_⟩ <;> rw [PerfectMatching.mem_edges]
      · rw [← hphi u 0 hPu]; exact congrArg φ h0
      · rw [← hphi u 1 hPu]; exact congrArg φ h1

/-! ## The transfer theorem and the equivalence -/

/-- **Transfer theorem for Máčajová–Škoviera.**  Assuming the finite Máčajová–Škoviera
conjecture, every locally finite graph without isolated vertices that admits *faithful*
finite cubic bridgeless local models satisfies the Máčajová–Škoviera property.

This is the analogue for `MacajovaSkoviera` of `bergeFulkerson_of_finite_local_models` and
`fanRaspaud_of_finite_local_models`; the extra injectivity of the modelling map is what
transports the parity of an odd cut into the finite model. -/
theorem macajovaSkoviera_of_injective_finite_local_models
    (hlf : ∀ v : V, (G.neighborSet v).Finite) (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (hMS : FiniteMacajovaSkovieraConjecture) (hmod : HasInjectiveFiniteLocalModels G) :
    MacajovaSkoviera G := by
  classical
  rw [macajovaSkoviera_iff_locallyApproximable hlf]
  intro T
  set T' : Finset V :=
    T.biUnion (fun j => match j with
      | Sum.inl v => insert v (hlf v).toFinset
      | Sum.inr S => S) with hT'
  obtain ⟨W, hWfin, K, φ, hcub, hbr, hiso, hinj⟩ := hmod T'
  obtain ⟨M₁, M₂, hMcut⟩ := hMS W hWfin K hcub hbr
  obtain ⟨c, hinvol, hcut⟩ := exists_msCond_of_localIso (G := G) φ ![M₁, M₂]
    (by simpa using hMcut) hne (fun v => v ∈ T') (fun v hv => hiso v hv)
  refine ⟨c, ?_⟩
  rintro (v | S) hj
  · have hv : v ∈ T' := Finset.mem_biUnion.mpr ⟨Sum.inl v, hj, Finset.mem_insert_self _ _⟩
    refine hinvol v hv (fun y hy => ?_)
    exact Finset.mem_biUnion.mpr ⟨Sum.inl v, hj, Finset.mem_insert_of_mem (by simpa using hy)⟩
  · intro hS
    have hsub : ∀ u ∈ S, u ∈ T' := fun u hu => Finset.mem_biUnion.mpr ⟨Sum.inr S, hj, hu⟩
    refine hcut S hsub (fun a ha b hb hab => ?_) hS
    exact hinj (Finset.mem_coe.mpr (hsub a (Finset.mem_coe.mp ha)))
      (Finset.mem_coe.mpr (hsub b (Finset.mem_coe.mp hb))) hab

/-- **The finite Máčajová–Škoviera conjecture is equivalent to its infinite version** on the
class of locally finite graphs without isolated vertices that admit faithful finite cubic
bridgeless local models.

`→` is the compactness transfer above; `←` holds because a finite cubic bridgeless graph is
its own faithful local model. -/
theorem finiteMacajovaSkoviera_iff :
    FiniteMacajovaSkovieraConjecture ↔
      ∀ (V : Type) (G : SimpleGraph V), (∀ v : V, (G.neighborSet v).Finite) →
        (∀ v : V, (G.neighborSet v).Nonempty) → HasInjectiveFiniteLocalModels G →
        MacajovaSkoviera G := by
  constructor
  · intro hMS V G hlf hne hmod
    exact macajovaSkoviera_of_injective_finite_local_models hlf hne hMS hmod
  · intro h W hW K hc hb
    haveI := hW
    exact h W K (fun _ => Set.toFinite _) (neighborSet_nonempty_of_isCubic hc)
      (hasInjectiveFiniteLocalModels_self K hc hb)

/-- On the faithful class the finite Berge–Fulkerson conjecture also transfers, since the
class is contained in `HasFiniteLocalModels`. -/
theorem bergeFulkerson_of_injective_finite_local_models
    (hlf : ∀ v : V, (G.neighborSet v).Finite) (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (hBF : FiniteBergeFulkersonConjecture) (hmod : HasInjectiveFiniteLocalModels G) :
    BergeFulkerson G :=
  bergeFulkerson_of_finite_local_models hlf hne hBF hmod.hasFiniteLocalModels

/-! ## The faithful class contains genuinely infinite graphs

A map injective on *every* finite set is injective, so a graph with infinitely many vertices
lying in `HasInjectiveFiniteLocalModels` must use larger and larger models.  Infinitely many
disjoint copies of a fixed finite cubic bridgeless graph is the simplest such example. -/

/-- `multiCopies ι K` is the disjoint union of `ι` copies of `K`. -/
def multiCopies (ι : Type*) (K : SimpleGraph W) : SimpleGraph (ι × W) where
  Adj p q := p.1 = q.1 ∧ K.Adj p.2 q.2
  symm := by
    rintro p q ⟨h1, h2⟩
    exact ⟨h1.symm, h2.symm⟩
  loopless := ⟨fun _ h => K.irrefl h.2⟩

@[simp] lemma multiCopies_adj {ι : Type*} {K : SimpleGraph W} (p q : ι × W) :
    (multiCopies ι K).Adj p q ↔ p.1 = q.1 ∧ K.Adj p.2 q.2 := Iff.rfl

lemma multiCopies_neighborSet {ι : Type*} {K : SimpleGraph W} (i : ι) (a : W) :
    (multiCopies ι K).neighborSet (i, a) = (fun b => (i, b)) '' K.neighborSet a := by
  ext ⟨j, b⟩
  simp only [SimpleGraph.mem_neighborSet, multiCopies_adj, Set.mem_image, Prod.mk.injEq]
  constructor
  · rintro ⟨rfl, h⟩
    exact ⟨b, h, rfl, rfl⟩
  · rintro ⟨b', hb', rfl, rfl⟩
    exact ⟨rfl, hb'⟩

theorem multiCopies_isCubic {ι : Type*} {K : SimpleGraph W} (hc : IsCubic K) :
    IsCubic (multiCopies ι K) := by
  rintro ⟨i, a⟩
  rw [multiCopies_neighborSet,
    Set.ncard_image_of_injective _ (fun b b' h => congrArg Prod.snd h)]
  exact hc a

/-- Copies of a bridgeless graph are bridgeless: reachability avoiding a deleted edge is
transported along the inclusion of a single copy. -/
theorem multiCopies_bridgeless {ι : Type*} {K : SimpleGraph W} (hb : Bridgeless K) :
    Bridgeless (multiCopies ι K) := by
  rintro e he hbridge
  induction e with
  | _ p q =>
    obtain ⟨i, a⟩ := p
    obtain ⟨j, b⟩ := q
    obtain ⟨hij, hadj⟩ : (i, a).1 = (j, b).1 ∧ K.Adj (i, a).2 (j, b).2 := he
    simp only at hij hadj
    subst hij
    rw [SimpleGraph.isBridge_iff] at hbridge
    obtain ⟨-, hreach⟩ := hbridge
    have hKreach : (K \ SimpleGraph.fromEdgeSet {s(a, b)}).Reachable a b := by
      by_contra h
      exact hb s(a, b) (by simpa using hadj) (SimpleGraph.isBridge_iff.mpr ⟨hadj, h⟩)
    refine hreach ?_
    let f : (K \ SimpleGraph.fromEdgeSet {s(a, b)}) →g
        (multiCopies ι K \ SimpleGraph.fromEdgeSet {s((i, a), (i, b))}) :=
      { toFun := fun c => (i, c)
        map_rel' := by
          rintro c d ⟨hcd, hnot⟩
          refine ⟨⟨rfl, hcd⟩, ?_⟩
          rw [SimpleGraph.fromEdgeSet_adj]
          rintro ⟨hmem, -⟩
          refine hnot ?_
          rw [SimpleGraph.fromEdgeSet_adj]
          refine ⟨?_, hcd.ne⟩
          rw [Set.mem_singleton_iff] at hmem ⊢
          rw [Sym2.eq_iff] at hmem ⊢
          rcases hmem with ⟨h1, h2⟩ | ⟨h1, h2⟩
          · exact Or.inl ⟨congrArg Prod.snd h1, congrArg Prod.snd h2⟩
          · exact Or.inr ⟨congrArg Prod.snd h1, congrArg Prod.snd h2⟩ }
    exact hKreach.map f

/-- `multiCopies ℕ K` is a genuinely infinite graph: it has infinitely many edges as soon as
`K` has one. -/
theorem multiCopies_edgeSet_infinite {K : SimpleGraph W} {a b : W} (hab : K.Adj a b) :
    ((multiCopies ℕ K).edgeSet).Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (f := fun n : ℕ => s(((n, a) : ℕ × W), ((n, b) : ℕ × W))) ?_ ?_
  · intro n m hnm
    rw [Sym2.eq_iff] at hnm
    rcases hnm with ⟨h1, -⟩ | ⟨h1, h2⟩
    · exact congrArg Prod.fst h1
    · exact absurd (congrArg Prod.snd h1) hab.ne
  · intro n
    rw [SimpleGraph.mem_edgeSet]
    exact ⟨rfl, hab⟩

theorem multiCopies_locallyFinite {ι : Type*} {K : SimpleGraph W} [Fintype W] (p : ι × W) :
    ((multiCopies ι K).neighborSet p).Finite := by
  obtain ⟨i, a⟩ := p
  rw [multiCopies_neighborSet]
  exact Set.Finite.image _ (Set.toFinite _)

/-- **The faithful class is genuinely infinite.**  Infinitely many disjoint copies of a
finite cubic bridgeless graph admit faithful finite local models: a window `T` only sees
finitely many copies, so finitely many copies already model it exactly. -/
theorem hasInjectiveFiniteLocalModels_multiCopies {W : Type} {K : SimpleGraph W} [Fintype W]
    (hc : IsCubic K) (hb : Bridgeless K) :
    HasInjectiveFiniteLocalModels (multiCopies ℕ K) := by
  classical
  intro T
  set N : ℕ := T.sup Prod.fst with hN
  refine ⟨Fin (N + 1) × W, inferInstance, multiCopies (Fin (N + 1)) K,
    fun p => (⟨min p.1 N, by omega⟩, p.2), multiCopies_isCubic hc, multiCopies_bridgeless hb,
    ?_, ?_⟩
  · rintro ⟨m, a⟩ -
    refine ⟨?_, ?_, ?_⟩
    · rintro ⟨m', a'⟩ ⟨hm, ha⟩
      simp only at hm ha
      subst hm
      exact ⟨rfl, ha⟩
    · rintro ⟨m₁, a₁⟩ ⟨m₂, a₂⟩ ⟨hm₁, ha₁⟩ ⟨hm₂, ha₂⟩ hEq
      simp only at hm₁ hm₂
      subst hm₁; subst hm₂
      have h2 : a₁ = a₂ := by simpa using congrArg Prod.snd hEq
      rw [h2]
    · rintro ⟨k, b⟩ ⟨hk, hab⟩
      simp only at hk hab
      exact ⟨(m, b), ⟨rfl, hab⟩, by rw [Prod.ext_iff]; exact ⟨hk.symm ▸ rfl, rfl⟩⟩
  · rintro ⟨m₁, a₁⟩ h₁ ⟨m₂, a₂⟩ h₂ hEq
    have hb₁ : m₁ ≤ N := Finset.le_sup (f := Prod.fst) (Finset.mem_coe.mp h₁)
    have hb₂ : m₂ ≤ N := Finset.le_sup (f := Prod.fst) (Finset.mem_coe.mp h₂)
    have h1 : min m₁ N = min m₂ N := congrArg Fin.val (congrArg Prod.fst hEq)
    have h2 : a₁ = a₂ := congrArg Prod.snd hEq
    rw [min_eq_left hb₁, min_eq_left hb₂] at h1
    exact Prod.ext h1 h2

/-! ### All three properties pass unconditionally to infinite disjoint unions

Berge–Fulkerson and Fan–Raspaud transfer because the projection onto the second coordinate is
a covering map.  Máčajová–Škoviera does *not* follow from covering — the image of an odd cut
need not be odd — and is proved below by a fibre-parity argument: an odd vertex set of the
disjoint union has an odd fibre, which is an odd cut of a single copy. -/

/-- The projection onto the copy is a covering map. -/
theorem isLocalIsoAt_multiCopies {ι : Type*} {K : SimpleGraph W} (p : ι × W) :
    IsLocalIsoAt (multiCopies ι K) K Prod.snd p where
  adj := fun _ h => h.2
  inj := by
    rintro ⟨i, a⟩ ⟨j, b⟩ ⟨hi, -⟩ ⟨hj, -⟩ hab
    simp only at hi hj hab
    exact Prod.ext (hi.symm.trans hj) hab
  surj := fun b hb => ⟨(p.1, b), ⟨rfl, hb⟩, rfl⟩

theorem multiCopies_bergeFulkerson {ι : Type*} {K : SimpleGraph W} (h : BergeFulkerson K) :
    BergeFulkerson (multiCopies ι K) :=
  BergeFulkerson.of_covering Prod.snd isLocalIsoAt_multiCopies h

theorem multiCopies_fanRaspaud {ι : Type*} {K : SimpleGraph W} (h : FanRaspaud K) :
    FanRaspaud (multiCopies ι K) :=
  FanRaspaud.of_covering Prod.snd isLocalIsoAt_multiCopies h

/-- A finite set of pairs of odd cardinality has a fibre of odd cardinality. -/
lemma exists_odd_fiber {α β : Type*} [DecidableEq α] (S : Finset (α × β)) (hS : Odd S.card) :
    ∃ i ∈ S.image Prod.fst, Odd {x ∈ S | x.1 = i}.card := by
  classical
  by_contra hcon
  push_neg at hcon
  have hsum : S.card = ∑ i ∈ S.image Prod.fst, {x ∈ S | x.1 = i}.card :=
    Finset.card_eq_sum_card_image Prod.fst S
  have heven : Even (∑ i ∈ S.image Prod.fst, {x ∈ S | x.1 = i}.card) := by
    rw [Finset.even_sum_iff_even_card_odd]
    have hempty : {i ∈ S.image Prod.fst | Odd {x ∈ S | x.1 = i}.card} = ∅ := by
      ext i
      simp only [Finset.mem_filter, Finset.notMem_empty, iff_false, not_and]
      exact fun hi => hcon i hi
    rw [hempty]
    simp
  rw [← hsum] at heven
  exact (Nat.not_odd_iff_even.mpr heven) hS

/-- A perfect matching of `K` acting copywise is a perfect matching of `multiCopies ι K`. -/
def PerfectMatching.multiCopiesLift {ι : Type*} {K : SimpleGraph W} (M : PerfectMatching K) :
    PerfectMatching (multiCopies ι K) where
  partner p := (p.1, M.partner p.2)
  isAdj p := ⟨rfl, M.isAdj p.2⟩
  invol p := by simp [M.invol]

/-- **The Máčajová–Škoviera property passes to infinite disjoint unions.**  Unlike
Berge–Fulkerson and Fan–Raspaud this is not an instance of the covering theorem: it needs the
parity of an odd vertex set to be located in a single copy. -/
theorem multiCopies_macajovaSkoviera {ι : Type*} {K : SimpleGraph W}
    (h : MacajovaSkoviera K) : MacajovaSkoviera (multiCopies ι K) := by
  classical
  obtain ⟨M₁, M₂, hM⟩ := h
  refine ⟨M₁.multiCopiesLift, M₂.multiCopiesLift, ?_⟩
  rintro C ⟨S, hSodd, rfl⟩ hsub
  obtain ⟨i, -, hodd⟩ := exists_odd_fiber S hSodd
  set F : Finset (ι × W) := {x ∈ S | x.1 = i} with hF
  set Si : Finset W := F.image Prod.snd with hSi
  have hmemSi : ∀ a : W, a ∈ Si ↔ (i, a) ∈ S := by
    intro a
    constructor
    · intro ha
      obtain ⟨q, hq, rfl⟩ := Finset.mem_image.mp ha
      obtain ⟨hqS, hq1⟩ := Finset.mem_filter.mp hq
      have hq' : ((q.1, q.2) : ι × W) ∈ S := by simpa using hqS
      rwa [hq1] at hq'
    · intro ha
      exact Finset.mem_image.mpr ⟨(i, a), Finset.mem_filter.mpr ⟨ha, rfl⟩, rfl⟩
  have hcard : Si.card = F.card :=
    Finset.card_image_of_injOn (by
      intro p hp q hq hpq
      have hp1 : p.1 = i := (Finset.mem_filter.mp (Finset.mem_coe.mp hp)).2
      have hq1 : q.1 = i := (Finset.mem_filter.mp (Finset.mem_coe.mp hq)).2
      exact Prod.ext (hp1.trans hq1.symm) hpq)
  have hSiodd : Odd Si.card := by rw [hcard]; exact hodd
  have hnot := hM (cutEdges K Si) ⟨Si, hSiodd, rfl⟩
  rw [Set.not_subset] at hnot
  obtain ⟨e, heC, heM⟩ := hnot
  obtain ⟨hEe, a, b, rfl, haS, hbS⟩ := heC
  have hab : K.Adj a b := by simpa using hEe
  have hmem : s(((i, a) : ι × W), ((i, b) : ι × W)) ∈ cutEdges (multiCopies ι K) S :=
    ⟨by simpa using (⟨rfl, hab⟩ : (multiCopies ι K).Adj (i, a) (i, b)), (i, a), (i, b), rfl,
      (hmemSi a).mp haS, fun hcon => hbS ((hmemSi b).mpr hcon)⟩
  obtain ⟨h1, h2⟩ := hsub hmem
  rw [PerfectMatching.mem_edges] at h1 h2
  refine heM ⟨?_, ?_⟩ <;> rw [PerfectMatching.mem_edges]
  · exact congrArg Prod.snd h1
  · exact congrArg Prod.snd h2

/-- Consequence: assuming only the *finite* Máčajová–Škoviera conjecture, the infinite graph
consisting of infinitely many disjoint copies of a finite cubic bridgeless graph satisfies
the Máčajová–Škoviera property. -/
theorem macajovaSkoviera_multiCopies_of_finite {W : Type} {K : SimpleGraph W} [Fintype W]
    [Nonempty W]
    (hMS : FiniteMacajovaSkovieraConjecture) (hc : IsCubic K) (hb : Bridgeless K) :
    MacajovaSkoviera (multiCopies ℕ K) :=
  macajovaSkoviera_of_injective_finite_local_models
    (fun v => multiCopies_locallyFinite v)
    (neighborSet_nonempty_of_isCubic (multiCopies_isCubic hc)) hMS
    (hasInjectiveFiniteLocalModels_multiCopies hc hb)

/-! ## A concrete infinite member of the faithful class

`K₄` is finite, cubic and bridgeless, so infinitely many disjoint copies of it form an
infinite cubic bridgeless graph in `HasInjectiveFiniteLocalModels` — and all three properties
hold for it *unconditionally*. -/

/-- An edge whose endpoints have a common neighbour distinct from both lies on a triangle,
hence is not a bridge. -/
lemma not_isBridge_of_common_neighbor {H : SimpleGraph V} {u v w : V}
    (huw : H.Adj u w) (hwv : H.Adj w v) (hwu : w ≠ u) (hwne : w ≠ v) :
    ¬ H.IsBridge s(u, v) := by
  rw [SimpleGraph.isBridge_iff]
  rintro ⟨-, hnr⟩
  refine hnr (SimpleGraph.reachable_delete_edges_iff_exists_walk.mpr
    ⟨SimpleGraph.Walk.cons huw (SimpleGraph.Walk.cons hwv SimpleGraph.Walk.nil), ?_⟩)
  simp only [SimpleGraph.Walk.edges_cons, SimpleGraph.Walk.edges_nil, List.mem_cons,
    List.not_mem_nil, or_false, not_or]
  constructor
  · intro h
    rw [Sym2.eq_iff] at h
    rcases h with ⟨-, h⟩ | ⟨h, -⟩
    · exact hwne h.symm
    · exact hwu h.symm
  · intro h
    rw [Sym2.eq_iff] at h
    rcases h with ⟨h, -⟩ | ⟨-, h⟩
    · exact hwu h.symm
    · exact hwne h.symm

/-- `K₄` is bridgeless: every edge lies on a triangle. -/
theorem k4_bridgeless : Bridgeless k4 := by
  intro e he hbr
  induction e with
  | _ u v =>
    obtain ⟨w, hwu, hwv⟩ : ∃ w : Fin 4, w ≠ u ∧ w ≠ v := by
      have h : ∀ a b : Fin 4, ∃ w : Fin 4, w ≠ a ∧ w ≠ b := by decide
      exact h u v
    exact not_isBridge_of_common_neighbor (show k4.Adj u w from Ne.symm hwu)
      (show k4.Adj w v from hwv) hwu hwv hbr

/-- **A concrete infinite, cubic, bridgeless graph with faithful finite local models for
which all three properties hold unconditionally**: infinitely many disjoint copies of `K₄`.
By `finiteMacajovaSkoviera_iff` this graph is a nontrivial instance of the class on which the
finite and the infinite Máčajová–Škoviera conjectures were proved equivalent. -/
theorem exists_infinite_cubic_bridgeless_faithful :
    ∃ (V : Type) (G : SimpleGraph V), IsCubic G ∧ Bridgeless G ∧ G.edgeSet.Infinite ∧
      HasInjectiveFiniteLocalModels G ∧ BergeFulkerson G ∧ FanRaspaud G ∧ MacajovaSkoviera G :=
  ⟨ℕ × Fin 4, multiCopies ℕ k4, multiCopies_isCubic k4_isCubic,
    multiCopies_bridgeless k4_bridgeless,
    multiCopies_edgeSet_infinite (show k4.Adj 0 1 by decide),
    hasInjectiveFiniteLocalModels_multiCopies k4_isCubic k4_bridgeless,
    multiCopies_bergeFulkerson k4_bergeFulkerson,
    multiCopies_fanRaspaud k4_bergeFulkerson.fanRaspaud,
    multiCopies_macajovaSkoviera k4_bergeFulkerson.macajovaSkoviera⟩

end Bridges.InfiniteCubicMatchings