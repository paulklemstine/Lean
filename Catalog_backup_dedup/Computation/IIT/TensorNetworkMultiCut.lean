import Mathlib
import Computation.IIT.TensorNetworkSchmidt

/-! # Multi-Cut Integrated Information of Tensor Networks

This file **synthesizes** two existing catalog developments of Tononi's Integrated
Information Theory (IIT):

* the *combinatorial* IIT skeleton (`Applications/Consciousness/IntegratedInformation.lean`),
  where the integrated information `Φ` of an `n`-element system is the **minimum** of an
  effective-information functional over all nontrivial bipartitions (the *Minimum
  Information Partition*, MIP); and
* the *quantum/tensor-network* development (`Computation/IIT/TensorNetworkSchmidt.lean`),
  where the single-cut integrated information of a bipartite pure state is `phiBip M =
  M.rank - 1`, one less than the **Schmidt rank**.

The single-cut `phiBip` only sees one bipartition. A genuine `n`-party tensor network is
cut in many ways, and IIT's defining move is to take the *worst* (least-information-loss)
cut. We package the Schmidt rank across every nontrivial bipartition as `CutData`, define
the multi-cut integrated information

  `phiMC S  :=  min over nontrivial cuts A of  (rank A - 1)`

and prove the IIT structural theorems in this quantum setting, culminating in the
**bond-dimension tightness theorem**: for a tensor network whose Schmidt rank across every
cut is capped by a bond dimension `D`, `Φ ≤ D - 1`, and this is *attained* by the network
that is maximally entangled across every cut (Schmidt rank `D` everywhere). The explicit
bond-dimension-`2` test case of the concept (`phiMC ≤ 1`) is a corollary, and is matched
to the single-cut `phiBip` of an identity (maximally entangled) coefficient matrix via
`phi_maximallyEntangled_eq` from the Schmidt file.

## Theorem declarations

1. `phiMC_le_cut` — `Φ ≤ rank A - 1` for every cut — proved — `Finset.min'_le`.
2. `exists_MIP` — a Minimum Information Partition exists and realizes `Φ` — proved —
   `Finset.min'_mem`.
3. `le_phiMC` — `Φ` is the greatest lower bound of the cut landscape — proved —
   `Finset.le_min'`.
4. `phiMC_eq_zero_iff` — reducibility: `Φ = 0` iff the network is a product state across
   some bipartition (Schmidt rank `1`) — proved — sandwich + `rank_pos`.
5. `phiMC_mono` — monotonicity in the Schmidt-rank data — proved — evaluate at the MIP.
6. `phiMC_le_bond` — bond dimension caps integrated information: ranks `≤ D ⟹ Φ ≤ D - 1`
   — proved — `le_phiMC`-free direct min bound.
7. `phiMC_bondTwo_le_one` — the concept's bond-dimension-`2` test: `Φ ≤ 1` — proved —
   specialize 6.
8. `phiMC_const` — a network with constant Schmidt rank `D` across all cuts has `Φ = D - 1`
   — proved — the image is a singleton value.
9. `phiMC_maximallyEntangled_tight` — **headline**: the maximally entangled network
   (Schmidt rank `D` across every cut) attains the bond bound, `Φ = D - 1`, certifying
   tightness; matched to `phiBip (1 : Matrix (Fin D) (Fin D) ℂ)` — proved.
-/

open Matrix Finset

namespace IIT.TensorNetwork.MultiCut

variable {n : ℕ}

/-- The nontrivial **bipartitions** (cuts) of an `n`-party tensor network: subsets `A` of
the parties that are neither empty nor everything. Each `A` encodes the cut separating `A`
from its complement. -/
def cuts (n : ℕ) : Finset (Finset (Fin n)) :=
  univ.powerset.filter (fun A => A.Nonempty ∧ A ≠ univ)

/-- Membership characterization for `cuts`. -/
theorem mem_cuts {A : Finset (Fin n)} : A ∈ cuts n ↔ A.Nonempty ∧ A ≠ univ := by
  simp [cuts]

-- !-- The singleton `{0}` is a nonempty proper subset when `n ≥ 2`, witnessing a cut. -- !--
/-- A tensor network on at least two parties always admits a nontrivial cut. -/
theorem cuts_nonempty (h : 2 ≤ n) : (cuts n).Nonempty := by
  refine ⟨{⟨0, by omega⟩}, ?_⟩
  rw [mem_cuts]
  refine ⟨singleton_nonempty _, ?_⟩
  intro hcontra
  have : (univ : Finset (Fin n)).card = 1 := by rw [← hcontra]; simp
  rw [Finset.card_univ, Fintype.card_fin] at this
  omega

/-- **Cut data** of an `n`-party tensor network state: the Schmidt rank across every
nontrivial bipartition. A nonzero state has Schmidt rank `≥ 1` across every cut. -/
structure CutData (n : ℕ) where
  /-- The Schmidt rank across the cut separating `A` from its complement. -/
  rank : Finset (Fin n) → ℕ
  /-- A nonzero pure state has positive Schmidt rank across every cut. -/
  rank_pos : ∀ A, 1 ≤ rank A

/-- **Multi-cut integrated information** `Φ` of a tensor network: the minimum, over all
nontrivial bipartitions, of the single-cut integrated information `rank A - 1`. This is the
quantum/Schmidt-rank instance of IIT's Minimum Information Partition. -/
def phiMC (S : CutData n) (h : 2 ≤ n) : ℕ :=
  ((cuts n).image (fun A => S.rank A - 1)).min' ((cuts_nonempty h).image (fun A => S.rank A - 1))

-- !-- `phiMC` is the minimum of the finite nonempty image, so `min'_le` at `rank A - 1`. -- !--
/-- `Φ` is a lower bound: no cut has integrated information below `Φ`. -/
theorem phiMC_le_cut (S : CutData n) (h : 2 ≤ n) {A : Finset (Fin n)} (hA : A ∈ cuts n) :
    phiMC S h ≤ S.rank A - 1 :=
  Finset.min'_le _ _ (Finset.mem_image_of_mem _ hA)

-- !-- `min'_mem` places `Φ` in the image; `mem_image` extracts the witnessing cut. -- !--
/-- **The Minimum Information Partition exists and realizes `Φ`.** Some nontrivial cut has
single-cut integrated information equal to the network's `Φ`. -/
theorem exists_MIP (S : CutData n) (h : 2 ≤ n) :
    ∃ A ∈ cuts n, S.rank A - 1 = phiMC S h := by
  obtain ⟨v, hv, hve⟩ := Finset.mem_image.mp (Finset.min'_mem _ ((cuts_nonempty h).image (fun A => S.rank A - 1)))
  exact ⟨v, hv, hve⟩

-- !-- Any common lower bound of the image is `≤` its minimum, by `Finset.le_min'`. -- !--
/-- `Φ` is the **greatest** lower bound of the cut landscape: any common lower bound `c` of
the per-cut integrated informations satisfies `c ≤ Φ`. -/
theorem le_phiMC (S : CutData n) (h : 2 ≤ n) {c : ℕ}
    (hc : ∀ A ∈ cuts n, c ≤ S.rank A - 1) : c ≤ phiMC S h := by
  apply Finset.le_min'
  intro y hy
  obtain ⟨A, hA, hAe⟩ := Finset.mem_image.mp hy
  exact hAe ▸ hc A hA

-- !-- Forward: the MIP cut has `rank A - 1 = 0`, and `rank A ≥ 1` forces `rank A = 1`.
--     Backward: `0 ≤ Φ ≤ rank A - 1 = 0`. -- !--
/-- **Reducibility characterization.** A tensor network is *reducible* (`Φ = 0`) exactly
when it is a **product state across some bipartition**, i.e. has Schmidt rank `1` across
some nontrivial cut. -/
theorem phiMC_eq_zero_iff (S : CutData n) (h : 2 ≤ n) :
    phiMC S h = 0 ↔ ∃ A ∈ cuts n, S.rank A = 1 := by
  constructor
  · intro H
    obtain ⟨A, hA, hAe⟩ := exists_MIP S h
    refine ⟨A, hA, ?_⟩
    have := S.rank_pos A
    omega
  · rintro ⟨A, hA, hAe⟩
    have hle := phiMC_le_cut S h hA
    omega

-- !-- Evaluate `T`'s MIP cut `A`: `Φ S ≤ rank_S A - 1 ≤ rank_T A - 1 = Φ T`. -- !--
/-- **Monotonicity.** If `S` has pointwise no larger Schmidt rank than `T` across every
cut, then `Φ S ≤ Φ T`. -/
theorem phiMC_mono (S T : CutData n) (h : 2 ≤ n)
    (hST : ∀ A, S.rank A ≤ T.rank A) : phiMC S h ≤ phiMC T h := by
  obtain ⟨A, hA, hAe⟩ := exists_MIP T h
  have h1 := phiMC_le_cut S h hA
  have h2 := hST A
  omega

-- !-- Every image point is `≤ D - 1`, so the minimum is too. -- !--
/-- **Bond dimension caps integrated information.** If the Schmidt rank across every cut is
at most the bond dimension `D`, then `Φ ≤ D - 1`. -/
theorem phiMC_le_bond (S : CutData n) (h : 2 ≤ n) {D : ℕ}
    (hbond : ∀ A ∈ cuts n, S.rank A ≤ D) : phiMC S h ≤ D - 1 := by
  obtain ⟨A, hA, hAe⟩ := exists_MIP S h
  have := hbond A hA
  omega

-- !-- Specialize the bond bound to `D = 2`, the concept's test case. -- !--
/-- The concept's explicit test: a tensor network whose Schmidt rank is at most `2` across
every cut (e.g. a bond-dimension-`2` MPS) has `Φ ≤ 1`. -/
theorem phiMC_bondTwo_le_one (S : CutData n) (h : 2 ≤ n)
    (hbond : ∀ A ∈ cuts n, S.rank A ≤ 2) : phiMC S h ≤ 1 :=
  phiMC_le_bond S h hbond

/-- The constant-Schmidt-rank tensor network: Schmidt rank `D ≥ 1` across every cut. -/
def constCutData (n : ℕ) (D : ℕ) (hD : 1 ≤ D) : CutData n where
  rank := fun _ => D
  rank_pos := fun _ => hD

-- !-- The image is the singleton `{D - 1}`, so its minimum is `D - 1`. -- !--
/-- A tensor network with constant Schmidt rank `D` across all cuts has `Φ = D - 1`. -/
theorem phiMC_const (n D : ℕ) (hD : 1 ≤ D) (h : 2 ≤ n) :
    phiMC (constCutData n D hD) h = D - 1 := by
  apply le_antisymm
  · obtain ⟨A, hA⟩ := cuts_nonempty h
    exact phiMC_le_cut (constCutData n D hD) h hA
  · apply le_phiMC
    intro A _
    rfl

-- !-- The constant network with `rank = D` saturates the bond bound `Φ ≤ D - 1`, so the
--     bound is tight; the per-cut value `D - 1` equals `phiBip (1 : Matrix (Fin D) (Fin D) ℂ)`
--     by `phi_maximallyEntangled_eq`. -- !--
/-- **Headline: bond-dimension tightness.** The bond bound `phiMC_le_bond` is tight: the
maximally entangled tensor network — Schmidt rank equal to the bond dimension `D` across
*every* bipartition — attains `Φ = D - 1`, the maximal value compatible with bond
dimension `D`. Moreover this per-cut maximum coincides with the single-cut integrated
information `phiBip` of the maximally entangled identity coefficient matrix on `Fin D ⊗
Fin D` from the Schmidt file. -/
theorem phiMC_maximallyEntangled_tight (n D : ℕ) [NeZero D] (hD : 1 ≤ D) (h : 2 ≤ n) :
    phiMC (constCutData n D hD) h = D - 1 ∧
      phiMC (constCutData n D hD) h = IIT.TensorNetwork.phiBip (1 : Matrix (Fin D) (Fin D) ℂ) := by
  refine ⟨phiMC_const n D hD h, ?_⟩
  rw [phiMC_const n D hD h, IIT.TensorNetwork.phi_maximallyEntangled_eq]

end IIT.TensorNetwork.MultiCut