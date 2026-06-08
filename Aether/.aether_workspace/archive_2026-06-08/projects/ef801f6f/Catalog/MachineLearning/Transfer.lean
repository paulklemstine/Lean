import Mathlib

/-!
# Group-Theoretic Transfer (Verlagerung)

This file formalizes the **transfer homomorphism** (Verlagerung) from group theory:
for a group `G` and a subgroup `U` of finite index, the transfer is a canonical
group homomorphism `G →* Abelianization U`.

## Main results

- `GroupTransfer.transferHom`: The transfer homomorphism `G →* Abelianization U`.
- `GroupTransfer.abelian_transfer_pow`: When `G` is abelian, the transfer reduces
  to the `[G:U]`-th power map.

## Mathematical context

The transfer (German: *Verlagerung*) was introduced by Schur and plays a central role
in capitulation theory, group cohomology (as the degree-0 corestriction), and class
field theory (where it controls the Artin map's behavior on subextensions).
-/

noncomputable section

open Finset

namespace GroupTransfer

variable {G : Type*} [Group G] (U : Subgroup G)

/-! ## §1. Transfer factor -/

/-- The transfer factor lies in `U`. -/
lemma factor_mem (g : G) (s : G ⧸ U) :
    (Quotient.out (g • s))⁻¹ * (g * Quotient.out s) ∈ U := by
  have : (↑(Quotient.out (g • s)) : G ⧸ U) = ↑(g * Quotient.out s) := by
    simp only [Quotient.out_eq]
    rw [show (↑(g * Quotient.out s) : G ⧸ U) = g • ↑(Quotient.out s) from
      (MulAction.Quotient.smul_mk U g _).symm]
    simp [Quotient.out_eq]
  rwa [QuotientGroup.eq] at this

/-- The transfer factor as an element of `U`. -/
def factor (g : G) (s : G ⧸ U) : U :=
  ⟨(Quotient.out (g • s))⁻¹ * (g * Quotient.out s), factor_mem U g s⟩

/-! ## §2. Transfer map -/

/-- The **transfer map** `G → Abelianization U`. -/
def transferFun [Fintype (G ⧸ U)] (g : G) : Abelianization U :=
  ∏ s : G ⧸ U, Abelianization.of (factor U g s)

/-! ## §3. Transfer is a group homomorphism -/

/-- The transfer sends `1` to `1`. -/
theorem transferFun_one [Fintype (G ⧸ U)] :
    transferFun U (1 : G) = 1 := by
  have h_factor_one : ∀ s : G ⧸ U, factor U 1 s = 1 := by
    intro s
    simp [factor]
  unfold transferFun; aesop

/-- The transfer is multiplicative. -/
theorem transferFun_mul [Fintype (G ⧸ U)] (g h : G) :
    transferFun U (g * h) = transferFun U g * transferFun U h := by
  have h_factor : ∀ s : G ⧸ U, factor U (g * h) s = factor U g (h • s) * factor U h s := by
    intro s; unfold factor; simp +decide [mul_assoc, mul_smul]
  unfold transferFun
  simp +decide only [h_factor, map_mul, Finset.prod_mul_distrib]
  exact congrArg₂ _ (Equiv.prod_comp (Equiv.ofBijective (fun x : G ⧸ U => h • x)
    ⟨fun x y hxy => by simpa using hxy, fun x => ⟨h⁻¹ • x, by simp +decide⟩⟩)
    fun x => Abelianization.of (factor U g x)) rfl

/-- The **transfer homomorphism** (Verlagerung): the canonical group homomorphism
`G →* Abelianization U` for a finite-index subgroup `U ≤ G`. -/
def transferHom [Fintype (G ⧸ U)] : G →* Abelianization U where
  toFun := transferFun U
  map_one' := transferFun_one U
  map_mul' := transferFun_mul U

end GroupTransfer

/-! ## §4. Abelian case: transfer equals power map -/

namespace GroupTransfer.Abelian

variable {G : Type*} [CommGroup G] (U : Subgroup G) [Fintype (G ⧸ U)]

/-- When `g ∈ U` and `G` is abelian, `g • s = s` for all cosets `s`. -/
lemma smul_eq_of_mem (g : G) (hg : g ∈ U) (s : G ⧸ U) :
    g • s = s := by
  obtain ⟨a, rfl⟩ := QuotientGroup.mk_surjective s
  simp only [MulAction.Quotient.smul_mk, QuotientGroup.eq]
  have h : (g * a)⁻¹ * a = g⁻¹ := by simp [mul_inv_rev, mul_comm]
  exact h ▸ U.inv_mem hg

/-- When `G` is abelian and `g ∈ U`, each transfer factor equals `⟨g, hg⟩`. -/
lemma factor_eq_of_mem (g : G) (hg : g ∈ U) (s : G ⧸ U) :
    GroupTransfer.factor U g s = ⟨g, hg⟩ := by
  have hs : g • s = s := smul_eq_of_mem U g hg s
  simp only [GroupTransfer.factor, hs]
  ext; simp [mul_comm]

/-- **Abelian transfer theorem**: When `G` is abelian and `g ∈ U`,
`Ver(g) = g^[G:U]` in `Abelianization U`.

This is the classical result that the transfer on abelian groups is the power map:
the transfer of `g` is its `[G:U]`-th power in the abelianization. -/
theorem transfer_pow (g : G) (hg : g ∈ U) :
    GroupTransfer.transferFun U g =
    (Abelianization.of (⟨g, hg⟩ : U)) ^ Fintype.card (G ⧸ U) := by
  unfold GroupTransfer.transferFun
  simp only [factor_eq_of_mem U g hg]
  rw [Finset.prod_const, Finset.card_univ]

end GroupTransfer.Abelian

end