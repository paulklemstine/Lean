import Geometry.SteaneCode
import Geometry.HypercubeIncidence

/-!
# Which binary CSS complexes come from a graph?  A rank obstruction

This file carries out **future target 2** of the research thread: *separate the
graph/simplicial model from the abstract chain-complex model*.  The previous
cycle proved a dimension theorem for arbitrary differentials over a field and
then applied it to a graph; the implicit assumption that every binary CSS
complex is realised by an incidence matrix of an actual `1`-complex is a
strictly stronger claim.  We refute it, with a clean necessary condition.

A `𝔽₂` matrix is a **graph incidence matrix** when every column is the indicator
of a pair of distinct vertices (`IsGraphIncidence`).  The key observation is a
*parity obstruction*: every such column has weight `2`, so the all-ones row
vector annihilates the matrix.  Hence

  `rank M + 1 ≤ #V`   (`IsGraphIncidence.rank_lt`),

i.e. the `X`-checks of a graph code are **never** independent.  Consequently any
CSS code whose `X`-check matrix has full row rank — for instance the Steane code
(`steaneH_not_graph_incidence`) — cannot be realised by a graph with its
standard incidence maps, however one chooses the vertex set.  The smallest
counterexample is the `1 × 1` matrix `[1]` (`one_by_one_not_graph_incidence`).

Conversely the hypercube boundary matrix built in
`Catalog/Geometry/HypercubeIncidence.lean` *is* a graph incidence matrix
(`incid_isGraphIncidence`), so the obstruction is not vacuous, and its
corank-one behaviour (`rank_incid_add_one`) is an instance of the general bound
above — an equality, since `Qₙ` is connected.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Representability by a `1`-complex is not automatic;
we conjecture a *linear-algebraic* obstruction visible already at the level of
ranks, not just a combinatorial one.

EXPERIMENT (Experimenter).  Every column of a graph incidence matrix has exactly
two `1`s, so its entries sum to `0` in `𝔽₂`: the all-ones vector lies in
`ker Mᵀ`, which forces `rank M < #V`.  Applied to `steaneH` (rank `3` on `3`
rows) this gives an immediate contradiction.

ANALYSIS (Analyst).  The condition is necessary but not sufficient: it says
nothing about the `Z`-side or about weights.  A full characterisation would have
to control the column weights (`2` for graphs, `k+1` for simplicial `k`-cells),
which is exactly the point of separating the models.

CRITIQUE (Critic).  `IsGraphIncidence` demands the two endpoints be *distinct*,
ruling out the degenerate "loop" columns; without that the obstruction fails,
since a loop column is `0`.  The counterexample is therefore stated with the
honest definition.
-/

namespace HQECC
namespace GraphRepresentability

open Matrix Module CSSDictionary

variable {V E : Type*} [Fintype V] [DecidableEq V] [Fintype E]

/-- `M` is the incidence matrix of a graph: every column is the indicator of a
pair of *distinct* vertices — the two endpoints of the corresponding edge. -/
def IsGraphIncidence (M : Matrix V E (ZMod 2)) : Prop :=
  ∀ e : E, ∃ u v : V, u ≠ v ∧
    ∀ w, M w e = (if w = u then 1 else 0) + (if w = v then 1 else 0)

omit [Fintype E] in
/-- **Parity obstruction.**  Each column of a graph incidence matrix has weight
`2`, hence sums to `0` over `𝔽₂`. -/
theorem IsGraphIncidence.column_sum {M : Matrix V E (ZMod 2)} (hM : IsGraphIncidence M)
    (e : E) : ∑ w, M w e = 0 := by
  obtain ⟨u, v, -, hcol⟩ := hM e
  simp only [hcol, Finset.sum_add_distrib, Finset.sum_ite_eq', Finset.mem_univ, if_true]
  decide

omit [Fintype E] in
/-- The all-ones vector is a cocycle of a graph incidence matrix. -/
theorem IsGraphIncidence.one_mem_ker {M : Matrix V E (ZMod 2)} (hM : IsGraphIncidence M) :
    (1 : V → ZMod 2) ∈ LinearMap.ker (Mᵀ.mulVecLin) := by
  ext e
  rw [Matrix.mulVecLin_apply]
  simpa [Matrix.mulVec, dotProduct, Matrix.transpose_apply] using hM.column_sum e

/-- **The checks of a graph code are never independent**: `rank M < #V`.
(The vertex set is nonempty because `V` carries the all-ones vector `≠ 0`.) -/
theorem IsGraphIncidence.rank_lt [Nonempty V] {M : Matrix V E (ZMod 2)}
    (hM : IsGraphIncidence M) : M.rank + 1 ≤ Fintype.card V := by
  have hone : (1 : V → ZMod 2) ≠ 0 := by
    intro h
    have := congrFun h (Classical.arbitrary V)
    simp at this
  have hker : 1 ≤ finrank (ZMod 2) (LinearMap.ker (Mᵀ.mulVecLin)) := by
    have hsub : Submodule.span (ZMod 2) {(1 : V → ZMod 2)} ≤ LinearMap.ker (Mᵀ.mulVecLin) := by
      rw [Submodule.span_le]
      rintro g rfl
      exact hM.one_mem_ker
    have h1 : finrank (ZMod 2) (Submodule.span (ZMod 2) {(1 : V → ZMod 2)}) = 1 :=
      finrank_span_singleton hone
    have := Submodule.finrank_mono hsub
    omega
  have hrn := LinearMap.finrank_range_add_finrank_ker (Mᵀ.mulVecLin)
  rw [Module.finrank_fintype_fun_eq_card] at hrn
  have hT : Mᵀ.rank = M.rank := Matrix.rank_transpose _
  have hrange : finrank (ZMod 2) (LinearMap.range (Mᵀ.mulVecLin)) = M.rank := hT
  omega

/-! ## The hypercube boundary matrix is a graph incidence matrix -/

open HypercubeIncidence in
/-- The hypercube boundary matrix of `HypercubeIncidence.lean` really is the
incidence matrix of a graph. -/
theorem incid_isGraphIncidence (n : ℕ) : IsGraphIncidence (incid n) := by
  intro e
  refine ⟨(e.2 : Vert n), (e.2 : Vert n) + bit e.1, ?_, fun w => rfl⟩
  intro h
  have h1 : ((e.2 : Vert n) + bit e.1) e.1 = (e.2 : Vert n) e.1 := by rw [← h]
  rw [Pi.add_apply, e.2.2] at h1
  simp [bit] at h1

/-! ## Counterexamples: CSS complexes with no graph model -/

/-- **The Steane code is not a graph code.**  Its `X`-check matrix has full row
rank `3`, contradicting `rank < #V` for any graph model on `3` vertices. -/
theorem steaneH_not_graph_incidence : ¬ IsGraphIncidence SteaneCode.steaneH := by
  intro h
  have := h.rank_lt
  rw [SteaneCode.steaneH_rank] at this
  simp at this

/-- **The minimal counterexample.**  The `1 × 1` matrix `[1]` is a perfectly
good binary differential (`d₁ = id`, `d₂ = 0` is a chain complex) but is not the
incidence matrix of any graph: a single column cannot be the indicator of two
distinct vertices among one vertex. -/
theorem one_by_one_not_graph_incidence :
    ¬ IsGraphIncidence (1 : Matrix (Fin 1) (Fin 1) (ZMod 2)) := by
  intro h
  obtain ⟨u, v, huv, -⟩ := h 0
  exact huv (Subsingleton.elim u v)

end GraphRepresentability
end HQECC