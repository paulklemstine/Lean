/-
# The multi-prime channel: the wall hierarchy at every arity

`PairLaw.lean` treats a semiprime `n = p·q`: two independent Frobenius classes, the pair
of factorization types against the abelianization coset of the product.  This file closes
the arity-`k` generalization that the previous cycle listed as an open direction
("Multi-Prime Wall Hierarchy").

Model: `k` independent uniform group elements `x : Fin k → G`, observables

* the **type vector** `i ↦ T (x i)`, and
* the **product coset** `∏ i, φ (x i)` for the abelianization homomorphism `φ : G →* A`
  (`A` abelian, so the product is a homomorphism on `G^k`).

Results:

* `multi_prime_law` — for every arity `k ≥ 1`, if the type determines the coset then the
  `k`-prime channel transmits exactly `log₂|A|` bits: pairing (or `k`-tupling) neither
  gains nor loses information.  So the single-prime value is an exact invariant of the
  arity.
* `multi_factor_wall` — for every arity `k ≥ 2`, the coset of the product is statistically
  independent of the coset of any *single* designated factor, so the mutual information of
  that pair is `0`: the "which factor" wall stands at every arity.
* `D5.multi_prime_mutualInfo` / `D5.multi_wall_mutualInfo` — the `D₅` quintic instance:
  `1` bit at every arity, wall exactly `0`.
-/
import MachineLearning.QuinticTypeChannel.PairLaw

open Finset

namespace TypeChannel
namespace MultiPrime

variable {ι A G : Type} [Fintype ι] [DecidableEq ι]
  [Fintype G] [DecidableEq G] [Group G] [Nonempty G]
  [CommGroup A] [Fintype A] [DecidableEq A]

/-- The coset observable of a `k`-almost-prime: the product of the `k` Frobenius cosets.
It is a homomorphism because the abelianization `A` is commutative. -/
def prodCosetHom (k : ℕ) (φ : G →* A) : (Fin k → G) →* A where
  toFun x := ∏ i, φ (x i)
  map_one' := by simp
  map_mul' x y := by simp [Finset.prod_mul_distrib]

omit [Fintype G] [DecidableEq G] [Nonempty G] [Fintype A] [DecidableEq A] in
@[simp] lemma prodCosetHom_apply (k : ℕ) (φ : G →* A) (x : Fin k → G) :
    prodCosetHom k φ x = ∏ i, φ (x i) := rfl

omit [Fintype G] [DecidableEq G] [Nonempty G] [Fintype A] [DecidableEq A] in
/-- On a "single factor" tuple — trivial outside one coordinate — the product coset is the
coset of that coordinate. -/
lemma prodCosetHom_mulSingle {k : ℕ} (φ : G →* A) (i : Fin k) (g : G) :
    prodCosetHom k φ (Pi.mulSingle i g) = φ g := by
  rw [prodCosetHom_apply]
  rw [Finset.prod_eq_single (f := fun j => φ ((Pi.mulSingle i g : Fin k → G) j)) i
    (fun j _ hj => by simp only [Pi.mulSingle_apply, if_neg hj, map_one])
    (fun hi => absurd (mem_univ i) hi), Pi.mulSingle_eq_same]

omit [Fintype G] [DecidableEq G] [Nonempty G] [Fintype A] [DecidableEq A] in
/-- `prodCosetHom` is surjective as soon as there is at least one factor. -/
lemma prodCosetHom_surjective {k : ℕ} (hk : 0 < k) {φ : G →* A}
    (hφ : Function.Surjective φ) : Function.Surjective (prodCosetHom k φ) := by
  intro a
  obtain ⟨g, hg⟩ := hφ a
  exact ⟨Pi.mulSingle ⟨0, hk⟩ g, by rw [prodCosetHom_mulSingle, hg]⟩

/-- The `k`-prime type/coset table: the vector of factorization types of the `k` prime
factors against the abelianization coset of their product. -/
noncomputable def multiTable (k : ℕ) (T : G → ι) (φ : G →* A) : Joint (Fin k → ι) A :=
  ofGroup (Fin k → G) (fun x i => T (x i)) (prodCosetHom k φ)

/-- **The multi-prime law.**  For every arity `k ≥ 1`, if the factorization type
determines the abelianization coset then the `k`-prime channel carries exactly `log₂|A|`
bits about the product coset — the single-prime value, verbatim, at every arity. -/
theorem multi_prime_law (k : ℕ) (hk : 0 < k) (T : G → ι) (φ : G →* A)
    (hφ : Function.Surjective φ) (hdet : ∀ g g' : G, T g = T g' → φ g = φ g') :
    (multiTable k T φ).mutualInfo = Real.logb 2 (Fintype.card A) := by
  have hdet' : ∀ x x' : Fin k → G, (fun i => T (x i)) = (fun i => T (x' i)) →
      prodCosetHom k φ x = prodCosetHom k φ x' := by
    intro x x' h
    simp only [prodCosetHom_apply]
    exact Finset.prod_congr rfl fun i _ => hdet (x i) (x' i) (congrFun h i)
  rw [multiTable, ofGroup_mutualInfo_eq_Hcoset _ _ _ hdet']
  exact Joint.Hcoset_of_uniform _
    (cosetMarg_ofGroup_hom _ (prodCosetHom k φ) (prodCosetHom_surjective hk hφ))

/-- The table pitting the coset of one designated factor against the coset of the product
of all `k + 2` factors. -/
noncomputable def multiWallTable (k : ℕ) (φ : G →* A) : Joint A A :=
  ofGroup (Fin (k + 2) → G)
    (φ.comp (Pi.evalMonoidHom (fun _ : Fin (k + 2) => G) 0)) (prodCosetHom (k + 2) φ)

omit [Fintype G] [DecidableEq G] [Nonempty G] [Fintype A] [DecidableEq A] in
lemma wall_jointly_surjective {k : ℕ} {φ : G →* A} (hφ : Function.Surjective φ) :
    Function.Surjective (fun x : Fin (k + 2) → G =>
      ((φ.comp (Pi.evalMonoidHom (fun _ : Fin (k + 2) => G) 0)) x, prodCosetHom (k + 2) φ x)) := by
  rintro ⟨a, b⟩
  obtain ⟨g₁, hg₁⟩ := hφ a
  obtain ⟨g₂, hg₂⟩ := hφ (a⁻¹ * b)
  refine ⟨(Pi.mulSingle 0 g₁ : Fin (k + 2) → G) * (Pi.mulSingle 1 g₂ : Fin (k + 2) → G), ?_⟩
  have hfst : ((Pi.mulSingle (0 : Fin (k + 2)) g₁ : Fin (k + 2) → G)
      * (Pi.mulSingle 1 g₂ : Fin (k + 2) → G)) 0 = g₁ := by
    simp [Pi.mul_apply]
  refine Prod.ext ?_ ?_
  · show φ (((Pi.mulSingle 0 g₁ : Fin (k + 2) → G)
      * (Pi.mulSingle 1 g₂ : Fin (k + 2) → G)) 0) = a
    rw [hfst, hg₁]
  · show prodCosetHom (k + 2) φ ((Pi.mulSingle 0 g₁ : Fin (k + 2) → G)
      * (Pi.mulSingle 1 g₂ : Fin (k + 2) → G)) = b
    rw [map_mul, prodCosetHom_mulSingle, prodCosetHom_mulSingle, hg₁, hg₂]
    group

/-- **The multi-factor wall.**  At every arity `k ≥ 2`, the coset of the product of the
`k` Frobenius classes is statistically independent of the coset of any single factor:
the residue of a `k`-almost-prime reveals nothing about which factor carried which
coset. -/
theorem multi_factor_wall (k : ℕ) (φ : G →* A) (hφ : Function.Surjective φ) :
    (multiWallTable k φ).mutualInfo = 0 := by
  refine Joint.mutualInfo_eq_zero_of_indep _ ?_
  intro a b
  rw [multiWallTable,
    p_ofGroup_hom_pair (φ.comp (Pi.evalMonoidHom (fun _ : Fin (k + 2) => G) 0))
      (prodCosetHom (k + 2) φ) (wall_jointly_surjective hφ) a b,
    typeMarg_ofGroup_hom (φ.comp (Pi.evalMonoidHom (fun _ : Fin (k + 2) => G) 0))
      (fun a => by
        obtain ⟨g, hg⟩ := hφ a
        exact ⟨Pi.mulSingle 0 g, by simpa [Pi.evalMonoidHom] using hg⟩) _ a,
    cosetMarg_ofGroup_hom _ (prodCosetHom (k + 2) φ)
      (prodCosetHom_surjective (Nat.succ_pos _) hφ) b]
  field_simp

/-- **Arity independence.**  Under the hypotheses of the multi-prime law the transmitted
information is the same at every arity: adding more prime factors to the semiprime neither
helps nor hurts. -/
theorem multi_prime_arity_independent (k l : ℕ) (hk : 0 < k) (hl : 0 < l) (T : G → ι)
    (φ : G →* A) (hφ : Function.Surjective φ) (hdet : ∀ g g' : G, T g = T g' → φ g = φ g') :
    (multiTable k T φ).mutualInfo = (multiTable l T φ).mutualInfo := by
  rw [multi_prime_law k hk T φ hφ hdet, multi_prime_law l hl T φ hφ hdet]

/-! ## The `D₅` cell at every arity -/

namespace D5

open DihedralD5 TypeChannel.PairLaw.D5

/-- **The `D₅` `k`-prime cell.**  For every `k ≥ 1` the vector of factorization types of
`k` primes carries exactly one bit about the abelianization coset of their product. -/
theorem multi_prime_mutualInfo (k : ℕ) (hk : 0 < k) :
    (multiTable k typeObs cosetHom).mutualInfo = 1 := by
  rw [multi_prime_law k hk typeObs cosetHom cosetHom_surjective typeObs_determines_cosetHom,
    card_C2]
  simp

/-- **The `D₅` which-factor wall is exactly zero at every arity `k ≥ 2`.** -/
theorem multi_wall_mutualInfo (k : ℕ) : (multiWallTable k cosetHom).mutualInfo = 0 :=
  multi_factor_wall k cosetHom cosetHom_surjective

end D5

end MultiPrime
end TypeChannel