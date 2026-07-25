import Mathlib

/-! # Integrated Information via Tensor Networks — Multipartite Minimum-Information Partition

This file lifts the bipartite Schmidt-rank picture of
`Computation.IIT.TensorNetworkSchmidt` to the genuinely multipartite setting that IIT
actually requires: a state on `n` sites, each of local dimension `d`, is an amplitude
tensor `ψ : (Fin n → Fin d) → ℂ`. Each bipartition `S ⊆ Fin n` reshapes `ψ` into a
matrix `cutMatrix (· ∈ S) ψ` whose rank is the Schmidt rank across that cut.

The IIT integrated information `Φ` is the value over the **minimum-information partition
(MIP)** — the bipartition that integrates the *least*. We model it as

  `phiMIP ψ := min_{S nontrivial} (schmidtRankAt S ψ - 1)`.

This is the direct multipartite generalization of `CausalSystem.phi` from
`Shared.CausalIntegration.Core` (min over `nontrivialBipartitions`), with the graph
cross-cut weight replaced by the quantum Schmidt rank across the cut.

Main results:
* `cutMatrix_rank_le_one_of_product` — if `ψ` factors as a product across a cut `S`, the
  Schmidt rank across `S` is ≤ 1.
* `phiMIP_eq_zero_of_product_cut` — the central IIT statement: if *any* nontrivial
  bipartition reduces the state to a product, then `Φ = 0`. (A system with a
  zero-integration partition is reducible.)
* `schmidtRankAt_le_block` — the Schmidt rank across `S` is bounded by the Hilbert-space
  dimension of the complementary block `d ^ |Sᶜ|` (area-law-style bound).
-/

open Matrix Finset

namespace IIT.Multipartite

variable {n d : ℕ}

/-- Reshape an `n`-site amplitude tensor `ψ` into the bipartite coefficient matrix across
the cut defined by predicate `p`: rows indexed by configurations of the `p`-block, columns
by configurations of its complement. -/
noncomputable def cutMatrix (p : Fin n → Prop) [DecidablePred p]
    (ψ : (Fin n → Fin d) → ℂ) :
    Matrix ({i // p i} → Fin d) ({i // ¬ p i} → Fin d) ℂ :=
  fun a b => ψ ((Equiv.piEquivPiSubtypeProd p (fun _ => Fin d)).symm (a, b))

/-- The Schmidt rank of the state `ψ` across the bipartition given by a finite set `S` of
sites: the rank of the reshaped coefficient matrix. -/
noncomputable def schmidtRankAt (S : Finset (Fin n)) (ψ : (Fin n → Fin d) → ℂ) : ℕ :=
  (cutMatrix (· ∈ S) ψ).rank

/-- The nontrivial bipartitions of `Fin n`: nonempty proper subsets. (Same indexing set as
`Shared.CausalIntegration.Core.nontrivialBipartitions`.) -/
def biparts (n : ℕ) : Finset (Finset (Fin n)) :=
  univ.powerset.filter (fun S => S.Nonempty ∧ S ≠ univ)

/-- Integrated information over the minimum-information partition: the least
`schmidtRankAt S ψ - 1` over all nontrivial bipartitions `S`. -/
noncomputable def phiMIP (ψ : (Fin n → Fin d) → ℂ) (hne : (biparts n).Nonempty) : ℕ :=
  (biparts n).inf' hne (fun S => schmidtRankAt S ψ - 1)

-- !-- Lab Notebook: cutMatrix_rank_le_one_of_product -- !--
-- !-- Hypothesis: If the amplitude tensor factorizes across a cut `S` as
--     `ψ(x) = f(x|_S) · g(x|_Sᶜ)`, the reshaped coefficient matrix is an outer product,
--     so the Schmidt rank across `S` is ≤ 1. -- !--
-- !-- Result: Proved. The reshape `cutMatrix (·∈S) ψ` equals `vecMulVec f g` pointwise
--     (the subtype index makes the `dite` from `piEquivPiSubtypeProd` collapse via
--     `i.2`), and `rank_vecMulVec_le` finishes. -- !--
-- !-- Insight: The subtype membership proof `i.2` is exactly what kills the
--     decidable-branch in the reshaping equivalence — the cleanest way to relate a
--     tensor factorization to outer-product matrix structure. -- !--
-- !-- Failure analysis: First `simp`-only attempt left a `dite` goal; resolving it by
--     `congr 1` then `dif_pos i.2 / dif_neg i.2` on each factor was the fix. -- !--
-- !-- End Lab Notebook -- !--

-- !-- A factorization `ψ(x)=f(x|_S)·g(x|_Sᶜ)` makes the reshaped matrix an outer product
--     `vecMulVec f g`, whose rank is ≤ 1. -- !--
/-- If `ψ` factors as a product across the cut `S`, the Schmidt rank across `S` is ≤ 1. -/
theorem cutMatrix_rank_le_one_of_product (S : Finset (Fin n))
    (f : ({i // i ∈ S} → Fin d) → ℂ) (g : ({i // i ∉ S} → Fin d) → ℂ)
    (ψ : (Fin n → Fin d) → ℂ)
    (hfac : ∀ x, ψ x = f (fun i => x i) * g (fun i => x i)) :
    schmidtRankAt S ψ ≤ 1 := by
  have hM : cutMatrix (· ∈ S) ψ = vecMulVec f g := by
    ext a b
    simp only [cutMatrix, vecMulVec, hfac, Equiv.piEquivPiSubtypeProd_symm_apply]
    congr 1
    · congr 1; funext i; rw [dif_pos i.2]
    · congr 1; funext i; rw [dif_neg i.2]
  simp only [schmidtRankAt, hM]
  exact rank_vecMulVec_le f g

-- !-- Lab Notebook: phiMIP_eq_zero_of_product_cut -- !--
-- !-- Hypothesis: A multipartite state is "reducible" (Φ = 0) as soon as ONE nontrivial
--     bipartition factorizes it into a product — the existence of a zero-integration
--     partition pins the minimum-information-partition value to 0. -- !--
-- !-- Result: Proved. `inf'_le` at the product cut `S` bounds `Φ` by
--     `schmidtRankAt S ψ - 1 = 0`, and Φ ≥ 0, so Φ = 0. -- !--
-- !-- Insight: This is the precise tensor-network analogue of
--     `phi_zero_of_disconnected`: a single decoupled cut suffices for global
--     reducibility. It is the *only-if* direction of the IIT conjecture
--     "Φ = 0 ⟺ state is a product across some cut". -- !--
-- !-- Failure analysis: None once `phiMIP` was defined via `inf'`; `omega` combines the
--     `inf'_le` bound with the rank-≤-1 lemma. -- !--
-- !-- End Lab Notebook -- !--

-- !-- `inf'_le` at the product cut `S` gives `Φ ≤ schmidtRankAt S ψ - 1 = 0`; with Φ ≥ 0,
--     conclude `Φ = 0`. -- !--
/-- **Reducibility ⟹ zero integration.** If some nontrivial bipartition `S` reduces the
state to a product, the minimum-information-partition integrated information is `0`. -/
theorem phiMIP_eq_zero_of_product_cut (ψ : (Fin n → Fin d) → ℂ)
    (S : Finset (Fin n)) (hS : S ∈ biparts n)
    (f : ({i // i ∈ S} → Fin d) → ℂ) (g : ({i // i ∉ S} → Fin d) → ℂ)
    (hfac : ∀ x, ψ x = f (fun i => x i) * g (fun i => x i)) :
    phiMIP ψ ⟨S, hS⟩ = 0 := by
  have hle : phiMIP ψ ⟨S, hS⟩ ≤ schmidtRankAt S ψ - 1 := Finset.inf'_le _ hS
  have h1 : schmidtRankAt S ψ ≤ 1 := cutMatrix_rank_le_one_of_product S f g ψ hfac
  omega

-- !-- Lab Notebook: schmidtRankAt_le_block -- !--
-- !-- Hypothesis: The Schmidt rank across any cut is capped by the Hilbert dimension of
--     the smaller block — the discrete shadow of the entanglement area law. -- !--
-- !-- Result: Proved (complement-block form). `rank ≤ #columns = d ^ |Sᶜ|` via
--     `rank_le_card_width`. -- !--
-- !-- Insight: Combined with `phi_mps_le_bond`, this shows two independent ceilings on
--     integration — geometric (block size) and algebraic (bond dimension); the MIP picks
--     the cut where their minimum is smallest. -- !--
-- !-- Failure analysis: None; `rank_le_card_width` applies verbatim after unfolding. -- !--
-- !-- End Lab Notebook -- !--

-- !-- `rank ≤ #columns` of the reshaped matrix, i.e. the dimension of the complement
--     block's configuration space, `d ^ |Sᶜ|`. -- !--
/-- The Schmidt rank across the cut `S` is bounded by the dimension of the complementary
block's configuration space (`= d ^ |Sᶜ|`): a discrete area-law-style bound. -/
theorem schmidtRankAt_le_block (S : Finset (Fin n)) (ψ : (Fin n → Fin d) → ℂ) :
    schmidtRankAt S ψ ≤ Fintype.card ({i // i ∉ S} → Fin d) := by
  simpa [schmidtRankAt] using (cutMatrix (· ∈ S) ψ).rank_le_card_width

end IIT.Multipartite