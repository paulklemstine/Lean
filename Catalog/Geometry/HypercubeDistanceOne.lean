import Geometry.CSSDistance
import Geometry.HypercubeIncidence

/-!
# The hypercube homological code has CSS distance `1`

The previous research cycle proved that the hypercube graph `Qₙ` has girth `4`
for every `n ≥ 2` and warned that the girth "should not be mistaken for the
complete quantum distance".  With the CSS distance now defined
(`Catalog/Geometry/CSSDistance.lean`) we can settle the question quantitatively.

The homological code `HQECC(Qₙ)` is the CSS code with
`H_X = ∂₁` (one `X`-check per vertex) and **no** `Z`-checks: a graph carries no
`2`-cells.  Its dual distance is the girth `4` (the lightest nonzero cycle), but
its *primal* distance is the lightest edge set that is **not** a cut, and a
single edge of `Qₙ` is not a cut, because it lies on a square.  Hence

  `dX = 1`   and therefore   `d = min(dX, dZ) = 1`.

So `HQECC(Qₙ)` corrects **no** errors: the parameters are `[[n·2ⁿ⁻¹,
2ⁿ⁻¹(n−2)+1, 1]]`, not `[[·, 1, 2^{n/2}]]`, and the girth `4` measures only one
of the two logical sectors.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  A graph code has trivial `Z`-stabilizer group, so
*every* edge subset is an undetectable `X`-error; its `X`-distance is the
minimal weight of a non-cut, which is `1` unless the graph has a bridge.  We
conjecture `dX(Qₙ) = 1` for all `n ≥ 2`, i.e. the true distance is `1`.

EXPERIMENT (Experimenter).  The witness is the indicator of a single edge.  The
proof that it is not a coboundary is a four-term telescoping identity around a
square of the cube: summing the coboundary condition over the four edges of the
square makes every vertex value appear twice, giving `0 = 1` in `𝔽₂`.

ANALYSIS (Analyst).  This isolates the error in the "systolic scaling" picture:
the systole of a *graph* controls only `dZ`.  Obtaining a growing CSS distance
requires genuine `2`-cells (as in the toric code), not just a high-girth graph.

CRITIQUE (Critic).  The result is a strict strengthening, not a restatement, of
the previous cycle's girth computation: it produces an explicit weight-one
undetectable nonstabilizer error, and `one_le_cssDistance` rules out the
degenerate value `0` coming from `Nat.sInf ∅ = 0`.
-/

namespace HQECC
namespace HypercubeDistanceOne

open Matrix CSSDictionary CSSDistance HypercubeIncidence

variable {n : ℕ}

/-- The `Z`-check matrix of a graph code: there are no `2`-cells, hence no
`Z`-checks. -/
def noZChecks (n : ℕ) : Matrix (Fin 0) (Edge n) (ZMod 2) := 0

/-- Two distinct directions of the cube, available as soon as `n ≥ 2`. -/
lemma exists_two_directions (hn : 2 ≤ n) : ∃ i0 i1 : Fin n, i0 ≠ i1 :=
  ⟨⟨0, by omega⟩, ⟨1, by omega⟩, by simp [Fin.ext_iff]⟩

/-- **A single edge is not a cut.**  For `n ≥ 2` the indicator function of the
edge `⟨i0, 0⟩` is not in the row space of the incidence matrix, i.e. it is not a
coboundary.  The proof adds the coboundary equation over the four edges of the
square spanned by the directions `i0 ≠ i1`. -/
theorem single_edge_not_coboundary (i0 i1 : Fin n) (h01 : i0 ≠ i1) :
    (Pi.single (⟨i0, ⟨0, rfl⟩⟩ : Edge n) 1 : Edge n → ZMod 2) ∉ rowSpace (incid n) := by
  rintro ⟨f, hf⟩
  rw [Matrix.mulVecLin_apply] at hf
  have h10 : i1 ≠ i0 := fun h => h01 h.symm
  have hb1i0 : (bit i1) i0 = 0 := by simp [bit, h01]
  have hb0i1 : (bit i0) i1 = 0 := by simp [bit, h10]
  -- the coboundary equation, at an arbitrary edge
  have key : ∀ e : Edge n, f (e.2 : Vert n) + f ((e.2 : Vert n) + bit e.1) =
      (Pi.single (⟨i0, ⟨0, rfl⟩⟩ : Edge n) 1 : Edge n → ZMod 2) e := by
    intro e
    rw [← incid_transpose_mulVec n f e, hf]
  -- the four edges of the square through `0` spanned by the directions `i0`, `i1`
  have k0 := key ⟨i0, ⟨0, rfl⟩⟩
  have ka := key ⟨i0, ⟨bit i1, hb1i0⟩⟩
  have kb := key ⟨i1, ⟨0, rfl⟩⟩
  have kc := key ⟨i1, ⟨bit i0, hb0i1⟩⟩
  simp only [zero_add] at k0 ka kb kc
  rw [Pi.single_eq_same] at k0
  rw [Pi.single_eq_of_ne (by
    intro h
    have hh : (bit i1 : Vert n) = 0 := congrArg (fun e : Edge n => (e.2 : Vert n)) h
    have h1 : (bit i1 : Vert n) i1 = 1 := by simp [bit]
    rw [hh] at h1
    exact absurd h1 (by simp)) 1] at ka
  rw [Pi.single_eq_of_ne (by intro h; exact h10 (congrArg Sigma.fst h)) 1] at kb
  rw [Pi.single_eq_of_ne (by intro h; exact h10 (congrArg Sigma.fst h)) 1] at kc
  rw [add_comm (bit i1) (bit i0)] at ka
  -- summing the four equations: every vertex value occurs twice, so `1 = 0`
  have square : ∀ p q r s : ZMod 2, (p + q) + ((r + s) + ((p + r) + (q + s))) = 0 := by decide
  have hcontra := square (f 0) (f (bit i0)) (f (bit i1)) (f (bit i0 + bit i1))
  rw [k0, ka, kb, kc] at hcontra
  exact absurd hcontra (by decide)

/-- The single-edge indicator has Hamming weight `1`. -/
lemma wt_single (e : Edge n) : wt (Pi.single e 1 : Edge n → ZMod 2) = 1 := by
  unfold wt
  rw [show (Finset.univ.filter (fun x => (Pi.single e 1 : Edge n → ZMod 2) x ≠ 0)) = {e} by
    ext x
    simp [Pi.single_apply, eq_comm]]
  simp

/-- **The primal distance of the hypercube graph code is `1`.** -/
theorem hypercube_dX_eq_one (hn : 2 ≤ n) : dX (incid n) (noZChecks n) = 1 := by
  obtain ⟨i0, i1, h01⟩ := exists_two_directions hn
  have hmem : (1 : ℕ) ∈ {w | ∃ a, XLogical (incid n) (noZChecks n) a ∧ wt a = w} := by
    refine ⟨Pi.single (⟨i0, ⟨0, rfl⟩⟩ : Edge n) 1, ⟨?_, single_edge_not_coboundary i0 i1 h01⟩,
      wt_single _⟩
    ext i
    exact absurd i.isLt (by omega)
  refine le_antisymm (Nat.sInf_le hmem) ?_
  by_contra hlt
  push_neg at hlt
  interval_cases h : dX (incid n) (noZChecks n)
  · obtain ⟨a, ha, hwa⟩ := Nat.sInf_mem (⟨1, hmem⟩ : Set.Nonempty _)
    rw [dX] at h
    rw [h] at hwa
    rw [wt_eq_zero_iff] at hwa
    subst hwa
    exact ha.2 (Submodule.zero_mem _)

/-- **The CSS distance of the hypercube homological code is `1`** for every
`n ≥ 2`: the code detects no error, in stark contrast with the girth `4` (which
bounds only the dual sector) and with the proposed value `2^{n/2}`. -/
theorem hypercube_cssDistance_eq_one (hn : 2 ≤ n) :
    cssDistance (incid n) (noZChecks n) = 1 := by
  obtain ⟨i0, i1, h01⟩ := exists_two_directions hn
  set a : Edge n → ZMod 2 := Pi.single (⟨i0, ⟨0, rfl⟩⟩ : Edge n) 1 with ha
  have hnoZ : noZChecks n *ᵥ a = 0 := by
    ext i
    exact absurd i.isLt (by omega)
  have hns : ((a, 0) : (Edge n → ZMod 2) × (Edge n → ZMod 2)) ∉ stab (incid n) (noZChecks n) := by
    rw [mem_stab_iff]
    rintro ⟨h1, -⟩
    exact single_edge_not_coboundary i0 i1 h01 h1
  have hmem : (1 : ℕ) ∈
      {w | ∃ p, Undetectable (incid n) (noZChecks n) p ∧ p ∉ stab (incid n) (noZChecks n) ∧
        wtPair p = w} := by
    refine ⟨(a, 0), ⟨hnoZ, by simp⟩, hns, ?_⟩
    rw [wtPair_left, ha, wt_single]
  refine le_antisymm (Nat.sInf_le hmem) (one_le_cssDistance _ _ ⟨1, hmem⟩)

end HypercubeDistanceOne
end HQECC