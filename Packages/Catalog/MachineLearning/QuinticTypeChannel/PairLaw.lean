/-
# The semiprime (pair) channel and the which-factor wall

A semiprime `n = p·q` presents *two* independent Frobenius classes at once.  The
experiment reads off the pair of factorization types `(T_p, T_q)` and asks how much it
says about the abelianization coset of the product, which is what the residue `n mod m*`
determines.

Model: two independent uniform group elements `(g₁, g₂) ∈ G × G`, observables
`(T g₁, T g₂)` and `φ g₁ · φ g₂` for the abelianization homomorphism `φ : G →* A`.

* `pair_law` — **the pair law**: if the type determines the coset, then the pair channel
  transmits `log₂|A|` bits, exactly the same as the single-prime channel.  For `D₅`
  (`|A| = 2`) this is the measured value `1.0000`.
* `which_factor_wall` — **the wall**: the product coset is statistically independent of
  the individual coset of the first factor, so the observable that identifies the product
  carries *zero* information about which factor contributed what.

Both are proved for arbitrary finite `G` with abelian quotient `A`, then instantiated at
the `D₅` quintic.
-/
import MachineLearning.QuinticTypeChannel.GroupTable
import MachineLearning.QuinticTypeChannel.DihedralD5

open Finset

namespace TypeChannel
namespace PairLaw

variable {ι A G : Type} [Fintype ι] [DecidableEq ι]
  [Fintype G] [DecidableEq G] [Group G] [Nonempty G]
  [CommGroup A] [Fintype A] [DecidableEq A]

/-- The coset observable of a semiprime: the product of the two Frobenius cosets. -/
def pairCosetHom (φ : G →* A) : G × G →* A :=
  (φ.comp (MonoidHom.fst G G)) * (φ.comp (MonoidHom.snd G G))

omit [Fintype G] [DecidableEq G] [Nonempty G] [Fintype A] [DecidableEq A] in
@[simp] lemma pairCosetHom_apply (φ : G →* A) (x : G × G) :
    pairCosetHom φ x = φ x.1 * φ x.2 := rfl

omit [Fintype G] [DecidableEq G] [Nonempty G] [Fintype A] [DecidableEq A] in
lemma pairCosetHom_surjective {φ : G →* A} (hφ : Function.Surjective φ) :
    Function.Surjective (pairCosetHom φ) := by
  intro a
  obtain ⟨g, hg⟩ := hφ a
  exact ⟨(g, 1), by simp [hg]⟩

/-- The semiprime type/coset table: the pair of factorization types against the product
coset. -/
noncomputable def pairTable (T : G → ι) (φ : G →* A) : Joint (ι × ι) A :=
  ofGroup (G × G) (fun x => (T x.1, T x.2)) (pairCosetHom φ)

/-- **The pair law.**  If the factorization type determines the abelianization coset, the
semiprime channel carries exactly `log₂|A|` bits — the same as the single-prime channel,
with no loss and no gain from pairing. -/
theorem pair_law (T : G → ι) (φ : G →* A) (hφ : Function.Surjective φ)
    (hdet : ∀ g g' : G, T g = T g' → φ g = φ g') :
    (pairTable T φ).mutualInfo = Real.logb 2 (Fintype.card A) := by
  have hdet' : ∀ x x' : G × G, (T x.1, T x.2) = (T x'.1, T x'.2) →
      pairCosetHom φ x = pairCosetHom φ x' := by
    intro x x' h
    rw [Prod.mk.injEq] at h
    simp only [pairCosetHom_apply]
    rw [hdet x.1 x'.1 h.1, hdet x.2 x'.2 h.2]
  rw [pairTable, ofGroup_mutualInfo_eq_Hcoset _ _ _ hdet']
  exact Joint.Hcoset_of_uniform _
    (cosetMarg_ofGroup_hom _ (pairCosetHom φ) (pairCosetHom_surjective hφ))

/-- The table pitting the coset of the *first* factor against the coset of the product. -/
noncomputable def wallTable (φ : G →* A) : Joint A A :=
  ofGroup (G × G) (φ.comp (MonoidHom.fst G G)) (pairCosetHom φ)

omit [Fintype G] [DecidableEq G] [Nonempty G] [Fintype A] [DecidableEq A] in
lemma wall_jointly_surjective {φ : G →* A} (hφ : Function.Surjective φ) :
    Function.Surjective
      (fun x : G × G => ((φ.comp (MonoidHom.fst G G)) x, pairCosetHom φ x)) := by
  rintro ⟨a, b⟩
  obtain ⟨g₁, hg₁⟩ := hφ a
  obtain ⟨g₂, hg₂⟩ := hφ (a⁻¹ * b)
  refine ⟨(g₁, g₂), ?_⟩
  simp [pairCosetHom_apply, hg₁, hg₂]

/-- **The which-factor wall.**  The coset of the product of two independent Frobenius
classes is statistically independent of the coset of either factor separately: the
semiprime residue reveals nothing about which factor carried which coset. -/
theorem which_factor_wall (φ : G →* A) (hφ : Function.Surjective φ) :
    (wallTable φ).mutualInfo = 0 := by
  refine Joint.mutualInfo_eq_zero_of_indep _ ?_
  intro a b
  rw [wallTable,
    p_ofGroup_hom_pair (φ.comp (MonoidHom.fst G G)) (pairCosetHom φ)
      (wall_jointly_surjective hφ) a b,
    typeMarg_ofGroup_hom (φ.comp (MonoidHom.fst G G))
      (fun a => by obtain ⟨g, hg⟩ := hφ a; exact ⟨(g, 1), hg⟩) _ a,
    cosetMarg_ofGroup_hom _ (pairCosetHom φ) (pairCosetHom_surjective hφ) b]
  field_simp

/-! ## The `D₅` semiprime cell -/

namespace D5

open DihedralD5

/-- The abelianization homomorphism of `D₅` as a map to the multiplicative `C₂`. -/
def cosetHom : D →* Multiplicative (ZMod 2) where
  toFun g := Multiplicative.ofAdd (match g with | .r _ => (0 : ZMod 2) | .sr _ => 1)
  map_one' := rfl
  map_mul' := by
    intro g h
    cases g <;> cases h <;>
      simp [DihedralGroup.r_mul_r, DihedralGroup.r_mul_sr, DihedralGroup.sr_mul_r,
        DihedralGroup.sr_mul_sr, ← ofAdd_add]
    decide

theorem cosetHom_surjective : Function.Surjective cosetHom := by
  intro a
  induction a using Multiplicative.rec with
  | _ z =>
    fin_cases z
    · exact ⟨DihedralGroup.r 0, rfl⟩
    · exact ⟨DihedralGroup.sr 0, rfl⟩

theorem typeObs_determines_cosetHom :
    ∀ g g' : D, typeObs g = typeObs g' → cosetHom g = cosetHom g' := by decide

theorem card_C2 : Fintype.card (Multiplicative (ZMod 2)) = 2 := by decide

/-- **The `D₅` semiprime cell**: the pair of factorization types of `p` and `q` carries
exactly one bit about the abelianization coset of `pq` — the pair law verbatim. -/
theorem pair_mutualInfo : (pairTable typeObs cosetHom).mutualInfo = 1 := by
  rw [pair_law typeObs cosetHom cosetHom_surjective typeObs_determines_cosetHom, card_C2]
  simp

/-- **The `D₅` which-factor wall is exactly zero.** -/
theorem wall_mutualInfo : (wallTable cosetHom).mutualInfo = 0 :=
  which_factor_wall cosetHom cosetHom_surjective

end D5

end PairLaw
end TypeChannel