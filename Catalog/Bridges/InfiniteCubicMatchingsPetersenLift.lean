/-
# Infinite ℤ-voltage lifts, and an infinite Berge–Fulkerson graph over the Petersen graph

The examples of §`InfiniteCubicMatchingsLadder` are all 3-edge-colourable, which makes the
Berge–Fulkerson property cheap.  Here we produce infinite witnesses over an arbitrary base:

* `zLift K vol` is the ℤ-voltage lift of a graph `K` along an antisymmetric voltage function.
  It is always an infinite graph covering `K` (`isLocalIsoAt_zLift`), it is cubic whenever `K`
  is (`zLift_isCubic`), and it inherits the Berge–Fulkerson and Fan–Raspaud properties
  (`zLift_bergeFulkerson`, `zLift_fanRaspaud`).
* `petersen` is the Petersen graph, the standard example of a cubic bridgeless graph that is
  **not** 3-edge-colourable.  Its six perfect matchings are written out explicitly and the
  Berge–Fulkerson condition is verified by kernel computation (`petersen_bergeFulkerson`).
* Consequently `zLift petersen vol` is an infinite cubic graph satisfying all three
  properties, obtained from a base that admits no proper 3-edge-colouring.
-/
import Bridges.InfiniteCubicMatchingsCovers

namespace Bridges.InfiniteCubicMatchings

universe v

/-! ## ℤ-voltage lifts -/

section ZLift

variable {W : Type v} (K : SimpleGraph W) (vol : W → W → ℤ)

/-- The ℤ-voltage lift of `K`: vertices are pairs `(m, u)`, and `(m,u)` is adjacent to
`(m + vol u v, v)` for every neighbour `v` of `u`. -/
def zLift (hvol : ∀ u v : W, vol v u = -vol u v) : SimpleGraph (ℤ × W) where
  Adj p q := K.Adj p.2 q.2 ∧ q.1 = p.1 + vol p.2 q.2
  symm := by
    rintro ⟨m, u⟩ ⟨n, v⟩ ⟨h1, h2⟩
    refine ⟨h1.symm, ?_⟩
    simp only at h2 ⊢
    rw [hvol u v, h2]
    ring
  loopless := ⟨by rintro ⟨m, u⟩ ⟨h1, -⟩; exact K.irrefl h1⟩

variable (hvol : ∀ u v : W, vol v u = -vol u v)

/-- The projection to the second coordinate is a covering map from the lift to the base. -/
theorem isLocalIsoAt_zLift (p : ℤ × W) : IsLocalIsoAt (zLift K vol hvol) K Prod.snd p where
  adj := fun _ h => h.1
  inj := by
    rintro ⟨n, v⟩ ⟨n', v'⟩ ⟨-, h2⟩ ⟨-, h4⟩ hv
    simp only at hv h2 h4
    subst hv
    simp only [Prod.mk.injEq, and_true]
    rw [h2, h4]
  surj := fun y hy => ⟨(p.1 + vol p.2 y, y), ⟨hy, rfl⟩, rfl⟩

theorem zLift_neighborSet (p : ℤ × W) :
    (zLift K vol hvol).neighborSet p = (fun y => (p.1 + vol p.2 y, y)) '' K.neighborSet p.2 := by
  ext ⟨n, v⟩
  simp only [SimpleGraph.mem_neighborSet, Set.mem_image]
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨v, h1, by simp only at h2; rw [h2]⟩
  · rintro ⟨y, hy, heq⟩
    rw [Prod.ext_iff] at heq
    obtain ⟨heq1, heq2⟩ := heq
    simp only at heq1 heq2
    subst heq2
    exact ⟨hy, by simp only; rw [heq1]⟩

theorem zLift_isCubic (hK : IsCubic K) : IsCubic (zLift K vol hvol) := by
  intro p
  rw [zLift_neighborSet, Set.InjOn.ncard_image]
  · exact hK p.2
  · intro a _ b _ hab
    exact (Prod.ext_iff.mp hab).2

/-- Berge–Fulkerson lifts from the base graph to any ℤ-voltage lift. -/
theorem zLift_bergeFulkerson (hK : BergeFulkerson K) : BergeFulkerson (zLift K vol hvol) :=
  BergeFulkerson.of_covering Prod.snd (isLocalIsoAt_zLift K vol hvol) hK

/-- Fan–Raspaud lifts from the base graph to any ℤ-voltage lift. -/
theorem zLift_fanRaspaud (hK : FanRaspaud K) : FanRaspaud (zLift K vol hvol) :=
  FanRaspaud.of_covering Prod.snd (isLocalIsoAt_zLift K vol hvol) hK

/-- A ℤ-voltage lift of a graph with at least one edge has infinitely many edges: the
whole ℤ-orbit of any base edge survives in the lift.  In particular the lift is a genuinely
infinite graph, not a finite one in disguise. -/
theorem zLift_edgeSet_infinite {u v : W} (huv : K.Adj u v) :
    ((zLift K vol hvol).edgeSet).Infinite := by
  apply Set.infinite_of_injective_forall_mem
    (f := fun n : ℤ => s((n, u), (n + vol u v, v)))
  · intro n m hnm
    rcases Sym2.eq_iff.mp hnm with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact congrArg Prod.fst h1
    · exact absurd (congrArg Prod.snd h1 : u = v) (K.ne_of_adj huv)
  · intro n
    exact ⟨huv, rfl⟩

end ZLift

/-! ## The Petersen graph -/

/-- Neighbour lists of the Petersen graph: outer 5-cycle `0..4`, inner pentagram `5..9`,
spokes `i — i+5`. -/
def petersenNbr : Fin 10 → List (Fin 10)
  | 0 => [1, 4, 5] | 1 => [0, 2, 6] | 2 => [1, 3, 7] | 3 => [2, 4, 8] | 4 => [0, 3, 9]
  | 5 => [0, 7, 8] | 6 => [1, 8, 9] | 7 => [2, 5, 9] | 8 => [3, 5, 6] | 9 => [4, 6, 7]

/-- The Petersen graph. -/
def petersen : SimpleGraph (Fin 10) where
  Adj u v := v ∈ petersenNbr u
  symm := by intro a b; revert a b; decide
  loopless := ⟨by decide⟩

instance : DecidableRel petersen.Adj :=
  fun u v => inferInstanceAs (Decidable (v ∈ petersenNbr u))

theorem petersen_isCubic : IsCubic petersen := by
  intro v
  rw [show petersen.neighborSet v = {u | u ∈ petersenNbr v} from rfl,
    Set.ncard_eq_toFinset_card', Set.toFinset_setOf]
  revert v
  decide

/-- The six perfect matchings of the Petersen graph, given by their partner tables. -/
def petersenPM : Fin 6 → Fin 10 → Fin 10
  | 0 => ![1, 0, 3, 2, 9, 7, 8, 5, 6, 4]
  | 1 => ![1, 0, 7, 4, 3, 8, 9, 2, 5, 6]
  | 2 => ![4, 2, 1, 8, 0, 7, 9, 5, 3, 6]
  | 3 => ![4, 6, 3, 2, 0, 8, 1, 9, 5, 7]
  | 4 => ![5, 2, 1, 4, 3, 0, 8, 9, 6, 7]
  | 5 => ![5, 6, 7, 8, 9, 0, 1, 2, 3, 4]

/-- Each table indeed defines a perfect matching of the Petersen graph. -/
def petersenMatching (i : Fin 6) : PerfectMatching petersen where
  partner := petersenPM i
  isAdj := by revert i; decide
  invol := by revert i; decide

/-- **The Petersen graph satisfies the Berge–Fulkerson property**: its six perfect matchings
cover every edge exactly twice. -/
theorem petersen_bergeFulkerson : BergeFulkerson petersen := by
  refine ⟨petersenMatching, ?_⟩
  intro e
  induction e with
  | _ u w =>
    intro hE
    have hset : {i : Fin 6 | s(u, w) ∈ (petersenMatching i).edges}
        = {i : Fin 6 | petersenPM i u = w} := by
      ext i
      simp only [Set.mem_setOf_eq, PerfectMatching.mem_edges]
      rfl
    have key : ∀ a b : Fin 10, b ∈ petersenNbr a →
        (Finset.univ.filter (fun i : Fin 6 => petersenPM i a = b)).card = 2 := by decide
    rw [hset, Set.ncard_eq_toFinset_card', Set.toFinset_setOf]
    exact key u w hE

theorem petersen_fanRaspaud : FanRaspaud petersen := petersen_bergeFulkerson.fanRaspaud

theorem petersen_macajovaSkoviera : MacajovaSkoviera petersen :=
  petersen_bergeFulkerson.macajovaSkoviera

/-! ## An infinite cubic Berge–Fulkerson graph over the Petersen graph -/

/-- A nonzero voltage assignment on the Petersen graph: the edge `0 — 1` gets voltage `1`,
every other edge voltage `0`. -/
def petersenVol (u v : Fin 10) : ℤ := if u = 0 ∧ v = 1 then 1 else if u = 1 ∧ v = 0 then -1 else 0

theorem petersenVol_antisymm (u v : Fin 10) : petersenVol v u = -petersenVol u v := by
  revert u v
  decide

/-- The infinite ℤ-lift of the Petersen graph along `petersenVol`. -/
abbrev petersenLift : SimpleGraph (ℤ × Fin 10) := zLift petersen petersenVol petersenVol_antisymm

theorem petersenLift_isCubic : IsCubic petersenLift :=
  zLift_isCubic petersen petersenVol petersenVol_antisymm petersen_isCubic

/-- **An infinite cubic graph, lifted from a base that is not 3-edge-colourable, satisfying
the Berge–Fulkerson property.** -/
theorem petersenLift_bergeFulkerson : BergeFulkerson petersenLift :=
  zLift_bergeFulkerson petersen petersenVol petersenVol_antisymm petersen_bergeFulkerson

theorem petersenLift_fanRaspaud : FanRaspaud petersenLift :=
  petersenLift_bergeFulkerson.fanRaspaud

theorem petersenLift_macajovaSkoviera : MacajovaSkoviera petersenLift :=
  petersenLift_bergeFulkerson.macajovaSkoviera

/-- The Petersen lift really is an infinite graph: it has infinitely many edges. -/
theorem petersenLift_edgeSet_infinite : (petersenLift.edgeSet).Infinite :=
  zLift_edgeSet_infinite petersen petersenVol petersenVol_antisymm
    (show petersen.Adj 0 1 by decide)

end Bridges.InfiniteCubicMatchings