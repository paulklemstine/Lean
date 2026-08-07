/-
# Cut parity in cubic graphs, and bridges versus finite sides

`InfiniteCubicMatchings.lean` proves that a graph possessing a **one-edge odd cut** satisfies
none of the three properties (`not_bergeFulkerson_of_oddCut_singleton` and friends), where
`IsOddCut G {e}` asks for a finite vertex set `S` of *odd* cardinality with
`cutEdges G S = {e}`.  In the finite world one never checks that parity by hand: a cubic graph
with a bridge automatically has an odd side, by the handshake lemma.  In the infinite world the
argument has to be redone for a *finite side of a possibly infinite graph*, and doing so was
next-cycle sub-conjecture 3 of `FUTURE_DIRECTIONS.md`.

This file proves it, in the sharpest form available.  The engine is
`cutEdges_finite_and_handshake`: for a cubic graph and **any** finite vertex set `S`, the cut
`cutEdges G S` is finite and

  `3 * S.card = 2 * m + (cutEdges G S).ncard`   for some `m`,

by a half-edge count — the set of pairs `(v, w)` with `v ∈ S` and `v` adjacent to `w` has
exactly `3 * S.card` elements; the pairs with `w ∈ S` form a set stable under a fixed-point-free
involution (swap), hence of even size; and the pairs with `w ∉ S` are in bijection with the cut.
Consequently `S.card` and `(cutEdges G S).ncard` always have the *same parity*
(`odd_card_iff_odd_ncard_cutEdges`), which is the infinite-graph form of the classical
"odd side ⟺ odd cut" for cubic graphs.

Consequences:

* `isOddCut_iff_odd_ncard` : for a cubic graph, `C` is an odd cut in the sense of `IsOddCut`
  iff it is the cut of some finite vertex set and has an odd number of edges;
* `isOddCut_singleton_iff` : in particular the parity hypothesis is automatic for one-edge
  cuts, so the obstruction in `not_bergeFulkerson_of_oddCut_singleton` is exactly
  "a one-edge cut with a finite side";
* `cutEdgesSet_bridgeSide` : the vertex set reachable from `u` after deleting a bridge
  `s(u, w)` has exactly `{s(u, w)}` as its cut;
* `not_bergeFulkerson_of_bridge_with_finite_side` (and the `FanRaspaud` / `MacajovaSkoviera`
  versions) : a cubic graph with a bridge one of whose sides is finite satisfies none of the
  three properties;
* `bridge_sides_infinite_of_bergeFulkerson` : hence, in a cubic graph satisfying
  Berge–Fulkerson, **every bridge separates two infinite sides**.  Together with
  `exists_bridged_cubic_bergeFulkerson` of `…Bridged.lean` this is sharp; the two halves are
  combined in `…BridgeSharp.lean`.
-/
import Bridges.InfiniteCubicMatchings

namespace Bridges.InfiniteCubicMatchings

universe u

variable {V : Type u} {G : SimpleGraph V}

/-! ## The half-edge count -/

/-- In a cubic graph every neighbour set is finite (an infinite set has `ncard = 0`). -/
lemma IsCubic.neighborSet_finite (hG : IsCubic G) (v : V) : (G.neighborSet v).Finite :=
  Set.finite_of_ncard_ne_zero (by rw [hG v]; omega)

/-- **The handshake lemma for a finite side of a cubic graph.**  For every finite vertex set
`S` of a cubic graph the edge cut of `S` is finite and `3 * S.card` exceeds its size by an even
number.  No finiteness of `V`, and no bridgelessness, is assumed. -/
theorem cutEdges_finite_and_handshake (hG : IsCubic G) (S : Finset V) :
    (cutEdges G S).Finite ∧ ∃ m : ℕ, 3 * S.card = 2 * m + (cutEdges G S).ncard := by
  classical
  have hfin : ∀ v : V, (G.neighborSet v).Finite := hG.neighborSet_finite
  -- the neighbours of `v`, as a `Finset`
  set N : V → Finset V := fun v => (hfin v).toFinset with hNdef
  have hNmem : ∀ v w : V, w ∈ N v ↔ G.Adj v w := by
    intro v w
    simp [hNdef]
  have hNcard : ∀ v, (N v).card = 3 := by
    intro v
    have h3 := hG v
    rwa [Set.ncard_eq_toFinset_card _ (hfin v)] at h3
  -- the half-edges based in `S`
  set D : Finset (V × V) := S.biUnion (fun v => (N v).image (fun w => (v, w))) with hDdef
  have hDmem : ∀ p : V × V, p ∈ D ↔ p.1 ∈ S ∧ G.Adj p.1 p.2 := by
    rintro ⟨a, b⟩
    constructor
    · intro hp
      rw [hDdef, Finset.mem_biUnion] at hp
      obtain ⟨v, hvS, hv⟩ := hp
      rw [Finset.mem_image] at hv
      obtain ⟨w, hw, hvw⟩ := hv
      cases hvw
      exact ⟨hvS, (hNmem _ _).mp hw⟩
    · rintro ⟨haS, hab⟩
      rw [hDdef, Finset.mem_biUnion]
      exact ⟨a, haS, Finset.mem_image.mpr ⟨b, (hNmem _ _).mpr hab, rfl⟩⟩
  have hDcard : D.card = 3 * S.card := by
    rw [hDdef, Finset.card_biUnion]
    · rw [Finset.sum_congr rfl (fun v _ => ?_), Finset.sum_const, smul_eq_mul, mul_comm]
      rw [Finset.card_image_of_injective _ (fun x y hxy => (Prod.mk.injEq _ _ _ _ ▸ hxy).2),
        hNcard v]
    · intro x _ y _ hxy
      simp only [Function.onFun]
      rw [Finset.disjoint_left]
      rintro ⟨a, b⟩ hx hy
      rw [Finset.mem_image] at hx hy
      obtain ⟨wx, -, hax⟩ := hx
      obtain ⟨wy, -, hay⟩ := hy
      rw [Prod.mk.injEq] at hax hay
      exact hxy (hax.1.trans hay.1.symm)
  -- split into inner and outgoing half-edges
  have hsplit : (D.filter fun p => p.2 ∈ S).card + (D.filter fun p => p.2 ∉ S).card = D.card :=
    Finset.card_filter_add_card_filter_not _
  -- the inner half-edges are permuted by `swap`, a fixed-point-free involution, so there is an
  -- even number of them
  have hinner : Even (D.filter fun p => p.2 ∈ S).card := by
    refine even_card_of_involutive _ Prod.swap ?_ (fun a _ => Prod.swap_swap a) ?_
    · rintro ⟨a, b⟩ hp
      rw [Finset.mem_filter, hDmem] at hp
      obtain ⟨⟨haS, hab⟩, hbS⟩ := hp
      rw [Finset.mem_filter, hDmem]
      exact ⟨⟨hbS, hab.symm⟩, haS⟩
    · rintro ⟨a, b⟩ hp
      rw [Finset.mem_filter, hDmem] at hp
      intro hcon
      exact hp.1.2.ne (congrArg Prod.fst hcon).symm
  -- the outgoing half-edges are in bijection with the cut
  set E : Finset (Sym2 V) := (D.filter fun p => p.2 ∉ S).image (fun p => s(p.1, p.2)) with hEdef
  have hEcoe : (↑E : Set (Sym2 V)) = cutEdges G S := by
    ext f
    constructor
    · intro hf
      rw [Finset.mem_coe, hEdef, Finset.mem_image] at hf
      obtain ⟨p, hp, rfl⟩ := hf
      rw [Finset.mem_filter, hDmem] at hp
      exact ⟨hp.1.2, p.1, p.2, rfl, hp.1.1, hp.2⟩
    · rintro ⟨hfE, a, b, rfl, haS, hbS⟩
      rw [Finset.mem_coe, hEdef, Finset.mem_image]
      exact ⟨(a, b), by rw [Finset.mem_filter, hDmem]; exact ⟨⟨haS, hfE⟩, hbS⟩, rfl⟩
  have hEcard : E.card = (D.filter fun p => p.2 ∉ S).card := by
    rw [hEdef]
    refine Finset.card_image_of_injOn ?_
    rintro ⟨a, b⟩ hp ⟨c, d⟩ hq hpq
    rw [Finset.mem_coe, Finset.mem_filter, hDmem] at hp hq
    rcases Sym2.eq_iff.mp hpq with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · rw [Prod.mk.injEq]
      exact ⟨h1, h2⟩
    · exact absurd (h1 ▸ hp.1.1) hq.2
  have hncard : (cutEdges G S).ncard = (D.filter fun p => p.2 ∉ S).card := by
    rw [← hEcoe, Set.ncard_coe_finset, hEcard]
  refine ⟨hEcoe ▸ E.finite_toSet, ?_⟩
  obtain ⟨m, hm⟩ := hinner
  refine ⟨m, ?_⟩
  rw [hncard]
  omega

/-- Cuts of finite vertex sets in a cubic graph are finite. -/
theorem cutEdges_finite (hG : IsCubic G) (S : Finset V) : (cutEdges G S).Finite :=
  (cutEdges_finite_and_handshake hG S).1

/-- **Cut parity.**  In a cubic graph a finite vertex set has odd cardinality exactly when its
edge cut has an odd number of edges. -/
theorem odd_card_iff_odd_ncard_cutEdges (hG : IsCubic G) (S : Finset V) :
    Odd S.card ↔ Odd (cutEdges G S).ncard := by
  obtain ⟨-, m, hm⟩ := cutEdges_finite_and_handshake hG S
  rw [Nat.odd_iff, Nat.odd_iff]
  omega

/-- **Odd cuts are exactly the cuts with an odd number of edges.**  For a cubic graph, the
definition of `IsOddCut` (an odd *vertex set* with a finite side) is equivalent to the usual
"the cut has odd size", so no parity bookkeeping on the vertex side is ever needed. -/
theorem isOddCut_iff_odd_ncard (hG : IsCubic G) (C : Set (Sym2 V)) :
    IsOddCut G C ↔ ∃ S : Finset V, C = cutEdges G S ∧ Odd C.ncard := by
  constructor
  · rintro ⟨S, hSodd, rfl⟩
    exact ⟨S, rfl, (odd_card_iff_odd_ncard_cutEdges hG S).mp hSodd⟩
  · rintro ⟨S, rfl, hodd⟩
    exact ⟨S, (odd_card_iff_odd_ncard_cutEdges hG S).mpr hodd, rfl⟩

/-- **The Máčajová–Škoviera property in edge terms.**  For a cubic graph the condition can be
stated entirely in terms of the *number of edges* of a cut, with no reference to the parity of
the vertex side: two perfect matchings work iff no cut with an odd number of edges (and a
finite side) is contained in their intersection.  This is the form in which the conjecture is
usually stated for finite graphs. -/
theorem macajovaSkoviera_iff_of_isCubic (hG : IsCubic G) :
    MacajovaSkoviera G ↔ ∃ M₁ M₂ : PerfectMatching G,
      ∀ S : Finset V, Odd (cutEdges G S).ncard → ¬ cutEdges G S ⊆ M₁.edges ∩ M₂.edges := by
  constructor
  · rintro ⟨M₁, M₂, h⟩
    exact ⟨M₁, M₂, fun S hS =>
      h _ ⟨S, (odd_card_iff_odd_ncard_cutEdges hG S).mpr hS, rfl⟩⟩
  · rintro ⟨M₁, M₂, h⟩
    refine ⟨M₁, M₂, ?_⟩
    rintro C ⟨S, hSodd, rfl⟩
    exact h S ((odd_card_iff_odd_ncard_cutEdges hG S).mp hSodd)

/-- **Handshake for a finite side.**  In a cubic graph, a finite vertex set whose edge cut is a
single edge has odd cardinality. -/
theorem odd_card_of_cutEdges_eq_singleton (hG : IsCubic G) (S : Finset V) {e : Sym2 V}
    (h : cutEdges G S = {e}) : Odd S.card :=
  (odd_card_iff_odd_ncard_cutEdges hG S).mpr (by rw [h, Set.ncard_singleton]; exact odd_one)

/-- **Exact characterisation of one-edge odd cuts in a cubic graph.**  The parity requirement
in `IsOddCut` is automatic for one-edge cuts: `{e}` is an odd cut iff it is the cut of some
finite vertex set at all. -/
theorem isOddCut_singleton_iff (hG : IsCubic G) (e : Sym2 V) :
    IsOddCut G {e} ↔ ∃ S : Finset V, cutEdges G S = {e} := by
  constructor
  · rintro ⟨S, -, hS⟩
    exact ⟨S, hS.symm⟩
  · rintro ⟨S, hS⟩
    exact ⟨S, odd_card_of_cutEdges_eq_singleton hG S hS, hS.symm⟩

/-! ## Bridges -/

/-- The set of vertices still reachable from `u` after deleting the edge `s(u, w)`. -/
def bridgeSide (G : SimpleGraph V) (u w : V) : Set V :=
  {x | (G \ SimpleGraph.fromEdgeSet {s(u, w)}).Reachable u x}

/-- If `s(u, w)` is a bridge, then its removal splits `G` and the side of `u` has exactly
`{s(u, w)}` as its edge cut. -/
theorem cutEdgesSet_bridgeSide {u w : V} (h : G.IsBridge s(u, w)) :
    cutEdgesSet G (bridgeSide G u w) = {s(u, w)} := by
  rw [SimpleGraph.isBridge_iff] at h
  obtain ⟨hadj, hnr⟩ := h
  apply Set.eq_singleton_iff_unique_mem.mpr
  refine ⟨⟨hadj, u, w, rfl, SimpleGraph.Reachable.refl u, hnr⟩, ?_⟩
  rintro f ⟨hfE, a, b, rfl, haS, hbS⟩
  by_contra hne
  -- if `s(a, b)` is not the deleted edge it survives the deletion, so `b` is on `u`'s side
  have hadj' : (G \ SimpleGraph.fromEdgeSet {s(u, w)}).Adj a b := by
    refine ⟨hfE, ?_⟩
    rintro ⟨hmem, -⟩
    exact hne (Set.mem_singleton_iff.mp hmem)
  exact hbS (haS.trans hadj'.reachable)

/-- A cubic graph with a bridge one of whose sides is finite has a one-edge odd cut. -/
theorem isOddCut_singleton_of_bridge_finite_side (hG : IsCubic G) {u w : V}
    (hbr : G.IsBridge s(u, w)) (hfin : (bridgeSide G u w).Finite) :
    IsOddCut G {s(u, w)} := by
  have hcut : cutEdges G hfin.toFinset = {s(u, w)} := by
    rw [cutEdges_eq_cutEdgesSet, hfin.coe_toFinset]
    exact cutEdgesSet_bridgeSide hbr
  exact (isOddCut_singleton_iff hG _).mpr ⟨hfin.toFinset, hcut⟩

theorem not_bergeFulkerson_of_bridge_with_finite_side (hG : IsCubic G) {u w : V}
    (hbr : G.IsBridge s(u, w)) (hfin : (bridgeSide G u w).Finite) : ¬ BergeFulkerson G :=
  not_bergeFulkerson_of_oddCut_singleton (isOddCut_singleton_of_bridge_finite_side hG hbr hfin)

theorem not_fanRaspaud_of_bridge_with_finite_side (hG : IsCubic G) {u w : V}
    (hbr : G.IsBridge s(u, w)) (hfin : (bridgeSide G u w).Finite) : ¬ FanRaspaud G :=
  not_fanRaspaud_of_oddCut_singleton (isOddCut_singleton_of_bridge_finite_side hG hbr hfin)

theorem not_macajovaSkoviera_of_bridge_with_finite_side (hG : IsCubic G) {u w : V}
    (hbr : G.IsBridge s(u, w)) (hfin : (bridgeSide G u w).Finite) : ¬ MacajovaSkoviera G :=
  not_macajovaSkoviera_of_oddCut_singleton
    (isOddCut_singleton_of_bridge_finite_side hG hbr hfin)

/-- **Every bridge of a cubic graph satisfying Máčajová–Škoviera separates two infinite
sides.**  (Since `BergeFulkerson → FanRaspaud → MacajovaSkoviera`, the same holds under either
of the two stronger hypotheses; see the corollaries below.)  This is sharp: `k4Chain` of
`…Bridged.lean` is an infinite cubic graph with infinitely many bridges — all of them with two
infinite sides — that satisfies all three properties. -/
theorem bridge_sides_infinite_of_macajovaSkoviera (hG : IsCubic G) (hMS : MacajovaSkoviera G)
    {u w : V} (hbr : G.IsBridge s(u, w)) :
    (bridgeSide G u w).Infinite ∧ (bridgeSide G w u).Infinite := by
  have hbr' : G.IsBridge s(w, u) := by rwa [Sym2.eq_swap] at hbr
  exact ⟨fun hfin => not_macajovaSkoviera_of_bridge_with_finite_side hG hbr hfin hMS,
    fun hfin => not_macajovaSkoviera_of_bridge_with_finite_side hG hbr' hfin hMS⟩

theorem bridge_sides_infinite_of_fanRaspaud (hG : IsCubic G) (hFR : FanRaspaud G)
    {u w : V} (hbr : G.IsBridge s(u, w)) :
    (bridgeSide G u w).Infinite ∧ (bridgeSide G w u).Infinite :=
  bridge_sides_infinite_of_macajovaSkoviera hG hFR.macajovaSkoviera hbr

theorem bridge_sides_infinite_of_bergeFulkerson (hG : IsCubic G) (hBF : BergeFulkerson G)
    {u w : V} (hbr : G.IsBridge s(u, w)) :
    (bridgeSide G u w).Infinite ∧ (bridgeSide G w u).Infinite :=
  bridge_sides_infinite_of_macajovaSkoviera hG hBF.macajovaSkoviera hbr

/-- In particular, a cubic graph satisfying Máčajová–Škoviera has an infinite vertex set as
soon as it has a bridge at all: bridgelessness can only fail infinitely. -/
theorem infinite_of_macajovaSkoviera_of_bridge (hG : IsCubic G) (hMS : MacajovaSkoviera G)
    {u w : V} (hbr : G.IsBridge s(u, w)) : Infinite V := by
  have h := (bridge_sides_infinite_of_macajovaSkoviera hG hMS hbr).1
  have : Infinite (bridgeSide G u w) := h.to_subtype
  exact Infinite.of_injective (Subtype.val : bridgeSide G u w → V) Subtype.val_injective

/-- The finite case of the classical statement, recovered: a **finite** cubic graph with a
bridge satisfies none of the three properties.  (Bridgelessness really is necessary in the
finite setting, while `…Bridged.lean` shows that it is not in the infinite one.) -/
theorem not_bergeFulkerson_of_bridge_of_finite [Finite V] (hG : IsCubic G) {u w : V}
    (hbr : G.IsBridge s(u, w)) : ¬ BergeFulkerson G :=
  not_bergeFulkerson_of_bridge_with_finite_side hG hbr (Set.toFinite _)

end Bridges.InfiniteCubicMatchings