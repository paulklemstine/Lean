/-
# Compactness: transferring the Berge–Fulkerson property from finite to infinite graphs

The paper *On some perfect matching conjectures in infinite, cubic, bridgeless graphs*
proves that the finite versions of the Berge–Fulkerson, Fan–Raspaud and Máčajová–Škoviera
conjectures are equivalent to their infinite versions.  The engine behind such statements is
a compactness (Rado selection / Tychonoff) argument.  This file formalises that engine.

Main results:

* `exists_forall_of_forall_finset` : a general compactness principle.  A constraint system on
  a product of *finite* sets, each constraint depending only on finitely many coordinates, is
  satisfiable as soon as every finite subsystem is.
* `bergeFulkerson_iff_locallyApproximable` : for a locally finite graph, the Berge–Fulkerson
  property is **finitary**: it holds iff every finite set of vertices carries a partial
  Berge–Fulkerson configuration.  (This is the exact local-to-global content of the transfer
  theorem.)
* `bergeFulkerson_of_finite_local_models` : if the *finite* Berge–Fulkerson conjecture holds
  and the (possibly infinite) locally finite graph `G` admits, around every finite set of
  vertices, a finite cubic bridgeless *local model*, then `G` satisfies Berge–Fulkerson.
-/
import Bridges.InfiniteCubicMatchings

namespace Bridges.InfiniteCubicMatchings

universe u v w

/-! ## A general compactness principle -/

/-- **Compactness principle.**  Let `K i` be finite sets and consider constraints `P j` on
the product `∀ i, K i`, each `P j` depending only on the coordinates in some finite set
`D j`.  If every finite subsystem of the constraints is satisfiable, the whole system is. -/
theorem exists_forall_of_forall_finset {ι : Type u} {K : ι → Type v} [∀ i, Finite (K i)]
    {J : Type w} (P : J → (∀ i, K i) → Prop)
    (hloc : ∀ j, ∃ D : Finset ι, ∀ c d : (∀ i, K i), (∀ i ∈ D, c i = d i) → P j c → P j d)
    (hfin : ∀ T : Finset J, ∃ c, ∀ j ∈ T, P j c) :
    ∃ c, ∀ j, P j c := by
  classical
  letI : ∀ i, TopologicalSpace (K i) := fun _ => ⊥
  haveI : ∀ i, DiscreteTopology (K i) := fun _ => ⟨rfl⟩
  haveI : ∀ i, CompactSpace (K i) := fun _ => Finite.compactSpace
  haveI : CompactSpace (∀ i, K i) := Pi.compactSpace
  set S : J → Set (∀ i, K i) := fun j => {c | P j c} with hS
  -- each constraint set is clopen, being determined by finitely many coordinates
  have hcyl : ∀ (D : Finset ι) (c : ∀ i, K i),
      IsOpen {d : ∀ i, K i | ∀ i ∈ D, c i = d i} := by
    intro D c
    have : {d : ∀ i, K i | ∀ i ∈ D, c i = d i} = ⋂ i ∈ D, (fun d : ∀ i, K i => d i) ⁻¹' {c i} := by
      ext d; simp [eq_comm]
    rw [this]
    exact isOpen_biInter_finset fun i _ => (continuous_apply i).isOpen_preimage _ (isOpen_discrete _)
  have hclosed : ∀ j, IsClosed (S j) := by
    intro j
    obtain ⟨D, hD⟩ := hloc j
    rw [← isOpen_compl_iff]
    rw [isOpen_iff_forall_mem_open]
    intro c hc
    refine ⟨{d | ∀ i ∈ D, c i = d i}, ?_, hcyl D c, fun i _ => rfl⟩
    intro d hd hdS
    exact hc (hD d c (fun i hi => (hd i hi).symm) hdS)
  have hne : ∀ T : Finset J, (⋂ j ∈ T, S j).Nonempty := by
    intro T
    obtain ⟨c, hc⟩ := hfin T
    exact ⟨c, by simpa [hS] using hc⟩
  obtain ⟨c, hc⟩ := CompactSpace.iInter_nonempty hclosed hne
  exact ⟨c, fun j => Set.mem_iInter.mp hc j⟩

/-! ## Berge–Fulkerson configurations -/

variable {V : Type u} {G : SimpleGraph V}

/-- A *Berge–Fulkerson configuration* assigns to every vertex a `6`-tuple of neighbours
(the candidate partners in the six matchings). -/
abbrev BFConfig (G : SimpleGraph V) := ∀ v : V, Fin 6 → G.neighborSet v

/-- The local Berge–Fulkerson condition at a vertex `v`: the six partner maps are
involutive at `v`, and every edge at `v` is used by exactly two of them. -/
def BFCond (G : SimpleGraph V) (c : BFConfig G) (v : V) : Prop :=
  (∀ i : Fin 6, ((c ((c v i : V)) i : V) = v)) ∧
  (∀ w ∈ G.neighborSet v, {i : Fin 6 | (c v i : V) = w}.ncard = 2)

/-- `G` is *Berge–Fulkerson locally approximable* if every finite set of vertices carries a
partial Berge–Fulkerson configuration. -/
def BFLocallyApproximable (G : SimpleGraph V) : Prop :=
  ∀ T : Finset V, ∃ c : BFConfig G, ∀ v ∈ T, BFCond G c v

/-- A configuration satisfying the Berge–Fulkerson condition everywhere yields six perfect
matchings covering every edge twice. -/
theorem bergeFulkerson_of_bfCond (c : BFConfig G) (hc : ∀ v, BFCond G c v) :
    BergeFulkerson G := by
  refine ⟨fun i => ⟨fun v => (c v i : V), fun v => (c v i).2, fun v => (hc v).1 i⟩, ?_⟩
  intro e
  induction e with
  | _ u w =>
    intro hE
    have hadj : G.Adj u w := hE
    have : {i : Fin 6 | s(u, w) ∈ (PerfectMatching.mk (fun v => (c v i : V))
        (fun v => (c v i).2) (fun v => (hc v).1 i) : PerfectMatching G).edges}
        = {i : Fin 6 | (c u i : V) = w} := by
      ext i
      simp only [Set.mem_setOf_eq, PerfectMatching.mem_edges]
    rw [this]
    exact (hc u).2 w hadj

/-- Conversely, the Berge–Fulkerson property gives a configuration valid at every vertex. -/
theorem exists_bfCond_of_bergeFulkerson (h : BergeFulkerson G) :
    ∃ c : BFConfig G, ∀ v, BFCond G c v := by
  obtain ⟨M, hM⟩ := h
  refine ⟨fun v i => ⟨(M i).partner v, (M i).isAdj v⟩, fun v => ⟨fun i => (M i).invol v, ?_⟩⟩
  intro w hw
  have hE : s(v, w) ∈ G.edgeSet := hw
  have := hM _ hE
  rwa [show {i : Fin 6 | s(v, w) ∈ (M i).edges} = {i : Fin 6 | (M i).partner v = w} by
    ext i; simp] at this

/-- **Local-to-global theorem for Berge–Fulkerson.**  For a locally finite graph, the
Berge–Fulkerson property is a finitary property: it holds if and only if every finite set of
vertices carries a partial Berge–Fulkerson configuration. -/
theorem bergeFulkerson_iff_locallyApproximable (hlf : ∀ v : V, (G.neighborSet v).Finite) :
    BergeFulkerson G ↔ BFLocallyApproximable G := by
  classical
  constructor
  · intro h T
    obtain ⟨c, hc⟩ := exists_bfCond_of_bergeFulkerson h
    exact ⟨c, fun v _ => hc v⟩
  · intro h
    haveI : ∀ v : V, Finite (G.neighborSet v) := fun v => (hlf v).to_subtype
    have hloc : ∀ v : V, ∃ D : Finset V, ∀ c d : BFConfig G,
        (∀ x ∈ D, c x = d x) → BFCond G c v → BFCond G d v := by
      intro v
      refine ⟨insert v (hlf v).toFinset, ?_⟩
      intro c d hagree hcv
      have hv : c v = d v := hagree v (Finset.mem_insert_self _ _)
      constructor
      · intro i
        have h1 : (d v i : V) = (c v i : V) := by rw [hv]
        have hmem : (c v i : V) ∈ insert v (hlf v).toFinset := by
          simp [Set.Finite.mem_toFinset, (c v i).2]
        have h2 : c ((c v i : V)) = d ((c v i : V)) := hagree _ hmem
        rw [h1, ← h2]
        exact hcv.1 i
      · intro w hw
        rw [show {i : Fin 6 | (d v i : V) = w} = {i : Fin 6 | (c v i : V) = w} by rw [hv]]
        exact hcv.2 w hw
    obtain ⟨c, hc⟩ := exists_forall_of_forall_finset (K := fun v : V => Fin 6 → G.neighborSet v)
      (fun v c => BFCond G c v) hloc h
    exact bergeFulkerson_of_bfCond c hc

/-! ## Finite local models: the finite conjecture transfers to infinite graphs -/

variable {W : Type v}

/-- `φ : V → W` is a *local isomorphism at `v`* from `G` to `K` if it maps the neighbours of
`v` injectively onto the neighbours of `φ v`. -/
structure IsLocalIsoAt (G : SimpleGraph V) (K : SimpleGraph W) (φ : V → W) (v : V) : Prop where
  /-- neighbours are sent to neighbours -/
  adj : ∀ x, G.Adj v x → K.Adj (φ v) (φ x)
  /-- distinct neighbours have distinct images -/
  inj : ∀ x y, G.Adj v x → G.Adj v y → φ x = φ y → x = y
  /-- every neighbour of `φ v` is hit -/
  surj : ∀ y, K.Adj (φ v) y → ∃ x, G.Adj v x ∧ φ x = y

/-- **Pullback of a Berge–Fulkerson family along a local isomorphism.**  If `φ` is a local
isomorphism at every vertex satisfying `P`, then a Berge–Fulkerson family of the model graph
`K` pulls back to a configuration satisfying the local Berge–Fulkerson condition at every
`P`-vertex all of whose neighbours are `P`-vertices. -/
theorem exists_bfCond_of_localIso {K : SimpleGraph W} (φ : V → W)
    (M : Fin 6 → PerfectMatching K)
    (hM : ∀ e ∈ K.edgeSet, {i : Fin 6 | e ∈ (M i).edges}.ncard = 2)
    (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (P : V → Prop) (hP : ∀ v, P v → IsLocalIsoAt G K φ v) :
    ∃ c : BFConfig G, ∀ v, P v → (∀ x, G.Adj v x → P x) → BFCond G c v := by
  classical
  have key : ∀ v : V, ∀ i : Fin 6, ∃ x : V, G.Adj v x ∧ (P v → φ x = (M i).partner (φ v)) := by
    intro v i
    by_cases h : P v
    · obtain ⟨x, hx, hxe⟩ := (hP v h).surj ((M i).partner (φ v)) ((M i).isAdj (φ v))
      exact ⟨x, hx, fun _ => hxe⟩
    · obtain ⟨x, hx⟩ := hne v
      exact ⟨x, hx, fun h' => absurd h' h⟩
  choose x hadj hphi using key
  refine ⟨fun v i => ⟨x v i, hadj v i⟩, ?_⟩
  intro v hv hvn
  constructor
  · intro i
    have h1 : φ (x v i) = (M i).partner (φ v) := hphi v i hv
    have hPw : P (x v i) := hvn _ (hadj v i)
    have h2 : φ (x (x v i) i) = (M i).partner (φ (x v i)) := hphi _ i hPw
    rw [h1, (M i).invol] at h2
    exact (hP _ hPw).inj _ _ (hadj (x v i) i) (hadj v i).symm h2
  · intro w hw
    have hwadj : G.Adj v w := hw
    have hEK : s(φ v, φ w) ∈ K.edgeSet := (hP v hv).adj w hwadj
    have hset : {i : Fin 6 | (x v i : V) = w} = {i : Fin 6 | s(φ v, φ w) ∈ (M i).edges} := by
      ext i
      simp only [Set.mem_setOf_eq, PerfectMatching.mem_edges]
      constructor
      · intro h
        rw [← h]
        exact (hphi v i hv).symm
      · intro h
        exact (hP v hv).inj _ _ (hadj v i) hwadj (by rw [hphi v i hv, h])
    rw [hset]
    exact hM _ hEK

/-- The Berge–Fulkerson conjecture for *finite* cubic bridgeless graphs. -/
def FiniteBergeFulkersonConjecture : Prop :=
  ∀ (W : Type) (_ : Fintype W) (K : SimpleGraph W), IsCubic K → Bridgeless K → BergeFulkerson K

/-- **Transfer theorem.**  Assume the finite Berge–Fulkerson conjecture.  If a locally finite
graph `G` with no isolated vertices admits, around every finite set of vertices, a *finite
cubic bridgeless local model*, then `G` itself satisfies the Berge–Fulkerson property.

This is the compactness half of the equivalence "finite version ⟺ infinite version": the
combinatorial input that remains is the construction of the finite local models. -/
theorem bergeFulkerson_of_finite_local_models
    (hlf : ∀ v : V, (G.neighborSet v).Finite) (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (hBF : FiniteBergeFulkersonConjecture)
    (hmodels : ∀ T : Finset V, ∃ (W : Type) (_ : Fintype W) (K : SimpleGraph W) (φ : V → W),
        IsCubic K ∧ Bridgeless K ∧ ∀ v ∈ T, IsLocalIsoAt G K φ v) :
    BergeFulkerson G := by
  classical
  rw [bergeFulkerson_iff_locallyApproximable hlf]
  intro T
  set T' : Finset V := T ∪ T.biUnion (fun v => (hlf v).toFinset) with hT'
  obtain ⟨W, hWfin, K, φ, hcub, hbr, hiso⟩ := hmodels T'
  obtain ⟨M, hM⟩ := hBF W hWfin K hcub hbr
  obtain ⟨c, hc⟩ := exists_bfCond_of_localIso (G := G) φ M hM hne (fun v => v ∈ T')
    (fun v hv => hiso v hv)
  refine ⟨c, fun v hv => hc v ?_ ?_⟩
  · exact Finset.mem_union_left _ hv
  · intro y hy
    refine Finset.mem_union_right _ (Finset.mem_biUnion.mpr ⟨v, hv, ?_⟩)
    simpa using hy

/-! ## The same for Fan–Raspaud and Máčajová–Škoviera

All three properties are *finitary*: they are determined by their restrictions to finite sets
of vertices.  We set up the two remaining cases with the same machinery. -/

/-- A `k`-tuple of candidate partners at each vertex. -/
abbrev MConfig (G : SimpleGraph V) (k : ℕ) := ∀ v : V, Fin k → G.neighborSet v

/-- The condition that the `k` partner maps are involutive at `v`. -/
def InvolCond (G : SimpleGraph V) {k : ℕ} (c : MConfig G k) (v : V) : Prop :=
  ∀ i : Fin k, ((c ((c v i : V)) i : V) = v)

/-- The `k` perfect matchings determined by a globally involutive configuration. -/
def toMatchings {k : ℕ} (c : MConfig G k) (h : ∀ v, InvolCond G c v) (i : Fin k) :
    PerfectMatching G :=
  ⟨fun v => (c v i : V), fun v => (c v i).2, fun v => h v i⟩

@[simp] lemma mem_toMatchings_edges {k : ℕ} (c : MConfig G k) (h : ∀ v, InvolCond G c v)
    (i : Fin k) (u w : V) : s(u, w) ∈ (toMatchings c h i).edges ↔ (c u i : V) = w := by
  simp only [PerfectMatching.mem_edges, toMatchings]

/-- Involutivity at `v` only depends on the coordinates of `v` and of its neighbours. -/
lemma involCond_local {k : ℕ} (v : V) (c d : MConfig G k) (hv : c v = d v)
    (hn : ∀ x ∈ G.neighborSet v, c x = d x) (hcv : InvolCond G c v) : InvolCond G d v := by
  intro i
  have h1 : (d v i : V) = (c v i : V) := by rw [hv]
  have h2 : c ((c v i : V)) = d ((c v i : V)) := hn _ (c v i).2
  rw [h1, ← h2]
  exact hcv i

/-! ### Fan–Raspaud -/

/-- The local Fan–Raspaud condition at `v`: the three partner maps are involutive at `v`, and
no edge at `v` is used by all three. -/
def FRCond (G : SimpleGraph V) (c : MConfig G 3) (v : V) : Prop :=
  InvolCond G c v ∧ ∀ w ∈ G.neighborSet v, ¬ ∀ i : Fin 3, (c v i : V) = w

/-- `G` is *Fan–Raspaud locally approximable* if every finite set of vertices carries a
partial Fan–Raspaud configuration. -/
def FRLocallyApproximable (G : SimpleGraph V) : Prop :=
  ∀ T : Finset V, ∃ c : MConfig G 3, ∀ v ∈ T, FRCond G c v

/-- **Local-to-global theorem for Fan–Raspaud.** -/
theorem fanRaspaud_iff_locallyApproximable (hlf : ∀ v : V, (G.neighborSet v).Finite) :
    FanRaspaud G ↔ FRLocallyApproximable G := by
  classical
  constructor
  · rintro ⟨M, hM⟩ T
    refine ⟨fun v i => ⟨(M i).partner v, (M i).isAdj v⟩, fun v _ => ⟨fun i => (M i).invol v, ?_⟩⟩
    intro w hw hall
    have : s(v, w) ∈ (M 0).edges ∩ (M 1).edges ∩ (M 2).edges := by
      refine ⟨⟨?_, ?_⟩, ?_⟩ <;> rw [PerfectMatching.mem_edges]
      · exact hall 0
      · exact hall 1
      · exact hall 2
    rw [hM] at this
    exact this
  · intro h
    haveI : ∀ v : V, Finite (G.neighborSet v) := fun v => (hlf v).to_subtype
    have hloc : ∀ v : V, ∃ D : Finset V, ∀ c d : MConfig G 3,
        (∀ x ∈ D, c x = d x) → FRCond G c v → FRCond G d v := by
      intro v
      refine ⟨insert v (hlf v).toFinset, fun c d hagree hcv => ⟨?_, ?_⟩⟩
      · refine involCond_local v c d (hagree v (Finset.mem_insert_self _ _)) ?_ hcv.1
        intro x hx
        exact hagree x (Finset.mem_insert_of_mem (by simpa using hx))
      · have hv : c v = d v := hagree v (Finset.mem_insert_self _ _)
        intro w hw hall
        exact hcv.2 w hw (fun i => by rw [hv]; exact hall i)
    obtain ⟨c, hc⟩ := exists_forall_of_forall_finset (K := fun v : V => Fin 3 → G.neighborSet v)
      (fun v c => FRCond G c v) hloc h
    refine ⟨toMatchings c (fun v => (hc v).1), ?_⟩
    rw [Set.eq_empty_iff_forall_notMem]
    intro e
    induction e with
    | _ u w =>
      rintro ⟨⟨h0, h1⟩, h2⟩
      rw [mem_toMatchings_edges] at h0 h1 h2
      have hadj : G.Adj u w := by
        have : G.Adj u (c u 0 : V) := (c u 0).2
        rwa [h0] at this
      refine (hc u).2 w hadj (fun i => ?_)
      fin_cases i
      · exact h0
      · exact h1
      · exact h2

/-! ### Máčajová–Škoviera -/

/-- The local Máčajová–Škoviera conditions, indexed by vertices (involutivity) and by finite
vertex sets (the odd cut condition). -/
def MSCond (G : SimpleGraph V) (c : MConfig G 2) : V ⊕ Finset V → Prop
  | Sum.inl v => InvolCond G c v
  | Sum.inr S => Odd S.card →
      ∃ u ∈ S, ∃ w, G.Adj u w ∧ w ∉ S ∧ ¬ ((c u 0 : V) = w ∧ (c u 1 : V) = w)

/-- `G` is *Máčajová–Škoviera locally approximable* if every finite family of local
conditions can be satisfied simultaneously. -/
def MSLocallyApproximable (G : SimpleGraph V) : Prop :=
  ∀ T : Finset (V ⊕ Finset V), ∃ c : MConfig G 2, ∀ j ∈ T, MSCond G c j

/-- **Local-to-global theorem for Máčajová–Škoviera.** -/
theorem macajovaSkoviera_iff_locallyApproximable (hlf : ∀ v : V, (G.neighborSet v).Finite) :
    MacajovaSkoviera G ↔ MSLocallyApproximable G := by
  classical
  constructor
  · rintro ⟨M₁, M₂, hM⟩ T
    refine ⟨fun v i => ⟨(![M₁, M₂] i).partner v, (![M₁, M₂] i).isAdj v⟩, ?_⟩
    rintro (v | S) -
    · exact fun i => (![M₁, M₂] i).invol v
    · intro hS
      have hnot := hM (cutEdges G S) ⟨S, hS, rfl⟩
      rw [Set.not_subset] at hnot
      obtain ⟨e, heC, heM⟩ := hnot
      obtain ⟨hEe, u, w, rfl, huS, hwS⟩ := heC
      have hadj : G.Adj u w := by simpa using hEe
      refine ⟨u, huS, w, hadj, hwS, ?_⟩
      rintro ⟨h0, h1⟩
      exact heM ⟨by simpa using h0, by simpa using h1⟩
  · intro h
    haveI : ∀ v : V, Finite (G.neighborSet v) := fun v => (hlf v).to_subtype
    have hloc : ∀ j : V ⊕ Finset V, ∃ D : Finset V, ∀ c d : MConfig G 2,
        (∀ x ∈ D, c x = d x) → MSCond G c j → MSCond G d j := by
      rintro (v | S)
      · refine ⟨insert v (hlf v).toFinset, fun c d hagree hcv => ?_⟩
        refine involCond_local v c d (hagree v (Finset.mem_insert_self _ _)) ?_ hcv
        intro x hx
        exact hagree x (Finset.mem_insert_of_mem (by simpa using hx))
      · refine ⟨S, fun c d hagree hcS hS => ?_⟩
        obtain ⟨u, huS, w, hadj, hwS, hne⟩ := hcS hS
        refine ⟨u, huS, w, hadj, hwS, ?_⟩
        rw [← hagree u huS]
        exact hne
    obtain ⟨c, hc⟩ := exists_forall_of_forall_finset
      (K := fun v : V => Fin 2 → G.neighborSet v) (fun j c => MSCond G c j) hloc h
    have hinv : ∀ v, InvolCond G c v := fun v => hc (Sum.inl v)
    refine ⟨toMatchings c hinv 0, toMatchings c hinv 1, ?_⟩
    rintro C ⟨S, hS, rfl⟩ hsub
    obtain ⟨u, huS, w, hadj, hwS, hne⟩ := hc (Sum.inr S) hS
    have hmem : s(u, w) ∈ cutEdges G S := ⟨by simpa using hadj, u, w, rfl, huS, hwS⟩
    obtain ⟨h0, h1⟩ := hsub hmem
    rw [mem_toMatchings_edges] at h0 h1
    exact hne ⟨h0, h1⟩

/-! ### Finite local models for Fan–Raspaud

The same pullback argument as for Berge–Fulkerson, one dimension lower. -/

/-- **Pullback of a Fan–Raspaud family along a local isomorphism.** -/
theorem exists_frCond_of_localIso {K : SimpleGraph W} (φ : V → W) (M : Fin 3 → PerfectMatching K)
    (hM : (M 0).edges ∩ (M 1).edges ∩ (M 2).edges = ∅)
    (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (P : V → Prop) (hP : ∀ v, P v → IsLocalIsoAt G K φ v) :
    ∃ c : MConfig G 3, ∀ v, P v → (∀ x, G.Adj v x → P x) → FRCond G c v := by
  classical
  have key : ∀ v : V, ∀ i : Fin 3, ∃ x : V, G.Adj v x ∧ (P v → φ x = (M i).partner (φ v)) := by
    intro v i
    by_cases h : P v
    · obtain ⟨x, hx, hxe⟩ := (hP v h).surj ((M i).partner (φ v)) ((M i).isAdj (φ v))
      exact ⟨x, hx, fun _ => hxe⟩
    · obtain ⟨x, hx⟩ := hne v
      exact ⟨x, hx, fun h' => absurd h' h⟩
  choose x hadj hphi using key
  refine ⟨fun v i => ⟨x v i, hadj v i⟩, ?_⟩
  intro v hv hvn
  constructor
  · intro i
    have h1 : φ (x v i) = (M i).partner (φ v) := hphi v i hv
    have hPw : P (x v i) := hvn _ (hadj v i)
    have h2 : φ (x (x v i) i) = (M i).partner (φ (x v i)) := hphi _ i hPw
    rw [h1, (M i).invol] at h2
    exact (hP _ hPw).inj _ _ (hadj (x v i) i) (hadj v i).symm h2
  · intro w hw hall
    have hall' : ∀ i : Fin 3, x v i = w := hall
    have h : ∀ i : Fin 3, s(φ v, φ w) ∈ (M i).edges := by
      intro i
      rw [PerfectMatching.mem_edges, ← hphi v i hv, hall' i]
    have hmem : s(φ v, φ w) ∈ (M 0).edges ∩ (M 1).edges ∩ (M 2).edges := ⟨⟨h 0, h 1⟩, h 2⟩
    rw [hM] at hmem
    exact hmem

/-- The Fan–Raspaud conjecture for *finite* cubic bridgeless graphs. -/
def FiniteFanRaspaudConjecture : Prop :=
  ∀ (W : Type) (_ : Fintype W) (K : SimpleGraph W), IsCubic K → Bridgeless K → FanRaspaud K

/-- **Transfer theorem for Fan–Raspaud.**  Assuming the finite Fan–Raspaud conjecture, a
locally finite graph without isolated vertices which has finite cubic bridgeless local models
around every finite vertex set satisfies Fan–Raspaud. -/
theorem fanRaspaud_of_finite_local_models
    (hlf : ∀ v : V, (G.neighborSet v).Finite) (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (hFR : FiniteFanRaspaudConjecture)
    (hmodels : ∀ T : Finset V, ∃ (W : Type) (_ : Fintype W) (K : SimpleGraph W) (φ : V → W),
        IsCubic K ∧ Bridgeless K ∧ ∀ v ∈ T, IsLocalIsoAt G K φ v) :
    FanRaspaud G := by
  classical
  rw [fanRaspaud_iff_locallyApproximable hlf]
  intro T
  set T' : Finset V := T ∪ T.biUnion (fun v => (hlf v).toFinset) with hT'
  obtain ⟨W, hWfin, K, φ, hcub, hbr, hiso⟩ := hmodels T'
  obtain ⟨M, hM⟩ := hFR W hWfin K hcub hbr
  obtain ⟨c, hc⟩ := exists_frCond_of_localIso (G := G) φ M hM hne (fun v => v ∈ T')
    (fun v hv => hiso v hv)
  refine ⟨c, fun v hv => hc v ?_ ?_⟩
  · exact Finset.mem_union_left _ hv
  · intro y hy
    refine Finset.mem_union_right _ (Finset.mem_biUnion.mpr ⟨v, hv, ?_⟩)
    simpa using hy

end Bridges.InfiniteCubicMatchings