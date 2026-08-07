/-
# Cayley graphs: infinite cubic Berge–Fulkerson graphs from finite quotients

A cubic Cayley graph `cayley S` of a group `Γ` (with `S` a three-element, inverse-closed
generating set of non-identity elements) is a covering of the Cayley graph of any quotient
`Γ →* Δ` on which the generators stay distinct and nontrivial (`isLocalIsoAt_cayley`).

Combining this with `BergeFulkerson.of_covering` gives a group-theoretic source of infinite
examples:

* `cayley_bergeFulkerson_of_quotient` — if the (possibly finite) quotient Cayley graph
  satisfies Berge–Fulkerson, so does the infinite one upstairs;
* `cayley_bergeFulkerson_of_finite_quotient` — assuming only the *finite* Berge–Fulkerson
  conjecture, every cubic Cayley graph of an infinite group with a suitable finite quotient
  satisfies Berge–Fulkerson;
* `ladderGroup_*` — a concrete instantiation with `Γ = ℤ × ℤ/2`, whose Cayley graph is the
  infinite ladder and whose finite quotients are the prisms.
-/
import Bridges.InfiniteCubicMatchingsCovers

namespace Bridges.InfiniteCubicMatchings

universe u v

section Cayley

variable {Γ : Type u} [Group Γ] {Δ : Type v} [Group Δ]

/-- The Cayley graph of `Γ` with respect to an inverse-closed set `S` of non-identity
elements: `x` and `y` are adjacent when `x⁻¹ * y ∈ S`. -/
def cayley (S : Set Γ) (hSinv : ∀ s ∈ S, s⁻¹ ∈ S) (hS1 : (1 : Γ) ∉ S) : SimpleGraph Γ where
  Adj x y := x⁻¹ * y ∈ S
  symm := by
    intro x y h
    have : y⁻¹ * x = (x⁻¹ * y)⁻¹ := by group
    rw [this]
    exact hSinv _ h
  loopless := ⟨by intro x hx; rw [inv_mul_cancel] at hx; exact hS1 hx⟩

variable (S : Set Γ) (hSinv : ∀ s ∈ S, s⁻¹ ∈ S) (hS1 : (1 : Γ) ∉ S)

lemma cayley_adj_iff (x y : Γ) : (cayley S hSinv hS1).Adj x y ↔ x⁻¹ * y ∈ S := Iff.rfl

lemma cayley_neighborSet (x : Γ) :
    (cayley S hSinv hS1).neighborSet x = (fun s => x * s) '' S := by
  ext y
  simp only [SimpleGraph.mem_neighborSet, cayley_adj_iff, Set.mem_image]
  constructor
  · intro h
    exact ⟨x⁻¹ * y, h, by group⟩
  · rintro ⟨s, hs, rfl⟩
    simpa using hs

/-- A Cayley graph on a three-element connection set is cubic. -/
theorem cayley_isCubic (hcard : S.ncard = 3) : IsCubic (cayley S hSinv hS1) := by
  intro x
  rw [cayley_neighborSet, Set.InjOn.ncard_image]
  · exact hcard
  · intro a _ b _ hab
    exact mul_left_cancel hab

/-- Right multiplication by an involution of the connection set is a perfect matching of the
Cayley graph. -/
def cayleyInvolutionMatching (b : Γ) (hb : b ∈ S) (hb2 : b * b = 1) :
    PerfectMatching (cayley S hSinv hS1) where
  partner x := x * b
  isAdj x := by
    show x⁻¹ * (x * b) ∈ S
    simpa [← mul_assoc] using hb
  invol x := by
    show x * b * b = x
    rw [mul_assoc, hb2, mul_one]

/-- **Every cubic Cayley graph on three involutions is properly 3-edge-colourable**, the
colour classes being right multiplication by the three generators.  In particular such a
graph — finite or infinite — satisfies Berge–Fulkerson. -/
theorem cayley_properThreeEdgeColoring_of_involutions (B : Fin 3 → Γ)
    (hB : Function.Injective B) (hmem : ∀ i, B i ∈ S) (hinvol : ∀ i, B i * B i = 1)
    (hsub : S ⊆ Set.range B) : ProperThreeEdgeColoring (cayley S hSinv hS1) := by
  refine ⟨fun i => cayleyInvolutionMatching S hSinv hS1 (B i) (hmem i) (hinvol i), ?_, ?_⟩
  · intro i j hij
    rw [Set.disjoint_left]
    intro e hei hej
    induction e with
    | _ x y =>
      rw [PerfectMatching.mem_edges] at hei hej
      exact absurd (hB (mul_left_cancel (hei.trans hej.symm))) hij
  · intro e
    induction e with
    | _ x y =>
      intro hE
      obtain ⟨i, hi⟩ := hsub (show x⁻¹ * y ∈ S from hE)
      refine ⟨i, ?_⟩
      rw [PerfectMatching.mem_edges]
      show x * B i = y
      rw [hi]
      group

/-- Berge–Fulkerson for cubic Cayley graphs on three involutions. -/
theorem cayley_bergeFulkerson_of_involutions (B : Fin 3 → Γ)
    (hB : Function.Injective B) (hmem : ∀ i, B i ∈ S) (hinvol : ∀ i, B i * B i = 1)
    (hsub : S ⊆ Set.range B) : BergeFulkerson (cayley S hSinv hS1) :=
  (cayley_properThreeEdgeColoring_of_involutions S hSinv hS1 B hB hmem hinvol hsub).bergeFulkerson

/-- **A group homomorphism induces a covering of Cayley graphs.**  If `f` is injective on the
connection set `S` and the image connection set avoids the identity, then `f` is a local isomorphism at every
vertex from `cayley S` onto the Cayley graph of the image connection set. -/
theorem isLocalIsoAt_cayley (f : Γ →* Δ) (hinj : Set.InjOn f S)
    (hTinv : ∀ t ∈ f '' S, t⁻¹ ∈ f '' S) (hT1 : (1 : Δ) ∉ f '' S) (x : Γ) :
    IsLocalIsoAt (cayley S hSinv hS1) (cayley (f '' S) hTinv hT1) f x where
  adj := by
    intro y hy
    show (f x)⁻¹ * f y ∈ f '' S
    have : (f x)⁻¹ * f y = f (x⁻¹ * y) := by simp
    rw [this]
    exact ⟨_, hy, rfl⟩
  inj := by
    intro y z hy hz hfyz
    have h1 : f (x⁻¹ * y) = f (x⁻¹ * z) := by simp [hfyz]
    have := hinj hy hz h1
    exact mul_left_cancel this
  surj := by
    intro z hz
    obtain ⟨s, hs, hfs⟩ : (f x)⁻¹ * z ∈ f '' S := hz
    refine ⟨x * s, ?_, ?_⟩
    · show (x)⁻¹ * (x * s) ∈ S
      simpa using hs
    · have : f (x * s) = f x * f s := by simp
      rw [this, hfs]
      group

/-- **Berge–Fulkerson descends from a quotient Cayley graph to the whole group.** -/
theorem cayley_bergeFulkerson_of_quotient (f : Γ →* Δ) (hinj : Set.InjOn f S) (hTinv : ∀ t ∈ f '' S, t⁻¹ ∈ f '' S) (hT1 : (1 : Δ) ∉ f '' S)
    (hQ : BergeFulkerson (cayley (f '' S) hTinv hT1)) : BergeFulkerson (cayley S hSinv hS1) :=
  BergeFulkerson.of_covering f (isLocalIsoAt_cayley S hSinv hS1 f hinj hTinv hT1) hQ

/-- The same statement for Fan–Raspaud. -/
theorem cayley_fanRaspaud_of_quotient (f : Γ →* Δ) (hinj : Set.InjOn f S) (hTinv : ∀ t ∈ f '' S, t⁻¹ ∈ f '' S) (hT1 : (1 : Δ) ∉ f '' S)
    (hQ : FanRaspaud (cayley (f '' S) hTinv hT1)) : FanRaspaud (cayley S hSinv hS1) :=
  FanRaspaud.of_covering f (isLocalIsoAt_cayley S hSinv hS1 f hinj hTinv hT1) hQ

/-- **The finite Berge–Fulkerson conjecture implies the Berge–Fulkerson property for every
cubic Cayley graph of an arbitrary — in particular infinite — group admitting a finite
quotient in which the three generators stay distinct and nontrivial and whose Cayley graph
is bridgeless.** -/
theorem cayley_bergeFulkerson_of_finite_quotient {Δ : Type} [Group Δ] [Fintype Δ]
    (f : Γ →* Δ) (hinj : Set.InjOn f S)
    (hTinv : ∀ t ∈ f '' S, t⁻¹ ∈ f '' S) (hT1 : (1 : Δ) ∉ f '' S)
    (hcard : (f '' S).ncard = 3) (hbr : Bridgeless (cayley (f '' S) hTinv hT1))
    (hBF : FiniteBergeFulkersonConjecture) : BergeFulkerson (cayley S hSinv hS1) :=
  cayley_bergeFulkerson_of_quotient S hSinv hS1 f hinj hTinv hT1
    (hBF Δ inferInstance _ (cayley_isCubic _ hTinv hT1 hcard) hbr)

end Cayley

/-! ## A concrete infinite cubic Cayley graph: the ladder group `ℤ × ℤ/2` -/

/-- The group `ℤ × ℤ/2`, written multiplicatively so that it is a `Group`. -/
abbrev LadderGroup := Multiplicative (ℤ × ZMod 2)

/-- The three generators `(±1, 0)` and `(0, 1)` of the ladder group. -/
def ladderGens : Set LadderGroup :=
  {Multiplicative.ofAdd (1, 0), Multiplicative.ofAdd (-1, 0), Multiplicative.ofAdd (0, 1)}

theorem ladderGens_inv_closed : ∀ s ∈ ladderGens, s⁻¹ ∈ ladderGens := by
  rintro s (rfl | rfl | rfl)
  · exact Or.inr (Or.inl (by decide))
  · exact Or.inl (by decide)
  · exact Or.inr (Or.inr (by decide))

theorem ladderGens_one_notMem : (1 : LadderGroup) ∉ ladderGens := by
  simp only [ladderGens]
  decide

/-- The Cayley graph of `ℤ × ℤ/2` on `{(±1,0), (0,1)}`: the infinite ladder. -/
abbrev ladderCayley : SimpleGraph LadderGroup :=
  cayley ladderGens ladderGens_inv_closed ladderGens_one_notMem

theorem ladderGens_ncard : ladderGens.ncard = 3 := by
  have h1 : (Multiplicative.ofAdd ((1 : ℤ), (0 : ZMod 2))) ∉
      ({Multiplicative.ofAdd ((-1 : ℤ), (0 : ZMod 2)),
        Multiplicative.ofAdd ((0 : ℤ), (1 : ZMod 2))} : Set LadderGroup) := by decide
  have h2 : (Multiplicative.ofAdd ((-1 : ℤ), (0 : ZMod 2))) ∉
      ({Multiplicative.ofAdd ((0 : ℤ), (1 : ZMod 2))} : Set LadderGroup) := by decide
  rw [ladderGens, Set.ncard_insert_of_notMem h1 (Set.toFinite _),
    Set.ncard_insert_of_notMem h2 (Set.toFinite _), Set.ncard_singleton]

theorem ladderCayley_isCubic : IsCubic ladderCayley :=
  cayley_isCubic _ _ _ ladderGens_ncard

/-! ## An infinite cubic Cayley graph on three involutions: the infinite dihedral group -/

open DihedralGroup

/-- Three distinct reflections of the infinite dihedral group `DihedralGroup 0`. -/
def dihGens : Set (DihedralGroup 0) := {sr 0, sr 1, sr 2}

theorem dihGens_inv_closed : ∀ s ∈ dihGens, s⁻¹ ∈ dihGens := by
  rintro s (rfl | rfl | rfl) <;> simp [dihGens, inv_sr]

theorem dihGens_one_notMem : (1 : DihedralGroup 0) ∉ dihGens := by
  have h : ∀ i : ZMod 0, (1 : DihedralGroup 0) ≠ sr i := by
    intro i hi
    simp only [one_def] at hi
    cases hi
  simp [dihGens, h]

/-- The Cayley graph of the infinite dihedral group on the three reflections
`sr 0, sr 1, sr 2`. -/
abbrev dihCayley : SimpleGraph (DihedralGroup 0) :=
  cayley dihGens dihGens_inv_closed dihGens_one_notMem

theorem dihGens_ncard : dihGens.ncard = 3 := by
  have h1 : (sr (0 : ZMod 0)) ∉ ({sr 1, sr 2} : Set (DihedralGroup 0)) := by decide
  have h2 : (sr (1 : ZMod 0)) ∉ ({sr 2} : Set (DihedralGroup 0)) := by decide
  rw [dihGens, Set.ncard_insert_of_notMem h1 (Set.toFinite _),
    Set.ncard_insert_of_notMem h2 (Set.toFinite _), Set.ncard_singleton]

theorem dihCayley_isCubic : IsCubic dihCayley :=
  cayley_isCubic _ _ _ dihGens_ncard

/-- **An infinite cubic graph satisfying Berge–Fulkerson, arising as a Cayley graph of the
infinite dihedral group on three involutions.** -/
theorem dihCayley_bergeFulkerson : BergeFulkerson dihCayley := by
  refine cayley_bergeFulkerson_of_involutions _ _ _ ![sr 0, sr 1, sr 2] ?_ ?_ ?_ ?_
  · intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all
  · intro i
    fin_cases i <;> simp [dihGens]
  · intro i
    fin_cases i <;> simp [sr_mul_sr]
  · rintro x (rfl | rfl | rfl)
    · exact ⟨0, rfl⟩
    · exact ⟨1, rfl⟩
    · exact ⟨2, rfl⟩

theorem dihCayley_fanRaspaud : FanRaspaud dihCayley :=
  dihCayley_bergeFulkerson.fanRaspaud

theorem dihCayley_macajovaSkoviera : MacajovaSkoviera dihCayley :=
  dihCayley_bergeFulkerson.macajovaSkoviera

/-- The dihedral Cayley graph really is infinite: it has infinitely many edges. -/
theorem dihCayley_edgeSet_infinite : dihCayley.edgeSet.Infinite := by
  apply Set.infinite_of_injective_forall_mem
    (f := fun n : ZMod 0 => s(r n, sr (-n)))
  · intro n m hnm
    rcases Sym2.eq_iff.mp hnm with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact r.inj h1
    · exact absurd h1 (by simp)
  · intro n
    show (r n)⁻¹ * sr (-n) ∈ dihGens
    rw [inv_r, r_mul_sr]
    simp [dihGens]

end Bridges.InfiniteCubicMatchings