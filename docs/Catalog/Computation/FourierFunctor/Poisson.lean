import Catalog.Computation.FourierFunctor.Exactness

/-!
# Poisson summation from annihilator duality

Fourth research cycle.  Combining the exactness results of `Exactness.lean`
(which give `|K^⊥| · |K| = |G|`) with the orthogonality relations, we prove the
**Poisson summation formula** for a subgroup `K` of a finite abelian group `G`:

`|G| · ∑_{k ∈ K} f k = |K| · ∑_{ψ ∈ K^⊥} 𝓕f ψ`.

The key intermediate result is `annihilator_sum`: the characters in the
annihilator of `K` sum to `|K^⊥|` on `K` and to `0` off `K` — an orthogonality
relation *relative to a subgroup*, proved from the existence of enough
characters on the quotient `G ⧸ K`.

-- !-- Lab Notes -- !--

* Hypothesizer (cycle 4): every classical summation formula of Fourier analysis
  should be a formal consequence of (i) the equivalence `pontryagin`, (ii) the
  orthogonality of characters, and (iii) the counting identity
  `|K^⊥| · |K| = |G|`.  Poisson summation is the test case.
* Experimenter: the subgroup orthogonality `annihilator_sum` was proved by the
  standard "translate the sum by a non-trivial element of the group being summed
  over" trick; the non-trivial character is produced on the quotient `G ⧸ K` and
  pulled back — which is precisely the *pullback* half of duality.
* Analyst: the two halves of duality appear in different roles: exactness
  (a categorical statement) supplies the *cardinality* `|K^⊥| = |G|/|K|`, while
  separation of points supplies the *vanishing* off `K`.  Poisson summation is
  their product.
* Critic: the formula is stated multiplicatively (`|G| · Σ = |K| · Σ`) rather
  than with a division, so it is valid verbatim in any characteristic-zero
  setting and no invertibility hypothesis is hidden.
-/

open CategoryTheory AddChar Finset
open scoped Classical

namespace FourierFunctor

variable {G : Type} [AddCommGroup G] [Fintype G]

/-- **Orthogonality relative to a subgroup.**  Summing all characters that are
trivial on `K` gives `|K^⊥|` at points of `K` and `0` elsewhere. -/
theorem annihilator_sum (K : AddSubgroup G) (x : G) :
    (∑ ψ : ↥(annihilator K), (ψ : AddChar G ℂ) x)
      = if x ∈ K then (Nat.card ↥(annihilator K) : ℂ) else 0 := by
  classical
  by_cases hx : x ∈ K
  · rw [if_pos hx]
    have hone : ∀ ψ : ↥(annihilator K), (ψ : AddChar G ℂ) x = 1 := fun ψ =>
      mem_annihilator.1 ψ.2 ⟨x, hx⟩
    rw [Finset.sum_congr rfl fun ψ _ => hone ψ]
    simp [Nat.card_eq_fintype_card]
  · rw [if_neg hx]
    have hxq : (QuotientAddGroup.mk' K) x ≠ 0 := fun h =>
      hx ((QuotientAddGroup.eq_zero_iff _).1 h)
    obtain ⟨χ, hχ⟩ := AddChar.exists_apply_ne_zero.2 hxq
    set ψ₀ : AddChar G ℂ := dualHom (QuotientAddGroup.mk' K) χ with hψ₀def
    have hmem : ψ₀ ∈ annihilator K := by
      refine mem_annihilator.2 fun k => ?_
      have : (QuotientAddGroup.mk' K) (k : G) = 0 := (QuotientAddGroup.eq_zero_iff _).2 k.2
      rw [hψ₀def, dualHom_apply, this, χ.map_zero_eq_one]
    have hx0 : ψ₀ x ≠ 1 := hχ
    set S : ℂ := ∑ ψ : ↥(annihilator K), (ψ : AddChar G ℂ) x with hS
    have hshift : ψ₀ x * S = S := by
      have hbij : Function.Bijective
          (fun ψ : ↥(annihilator K) => (⟨ψ₀, hmem⟩ : ↥(annihilator K)) + ψ) :=
        (Equiv.addLeft (⟨ψ₀, hmem⟩ : ↥(annihilator K))).bijective
      have := Fintype.sum_bijective _ hbij
        (fun ψ : ↥(annihilator K) => ψ₀ x * (ψ : AddChar G ℂ) x)
        (fun ψ : ↥(annihilator K) => (ψ : AddChar G ℂ) x)
        (fun ψ => by
          simp only [AddSubgroup.coe_add, AddChar.add_apply])
      rw [hS, Finset.mul_sum]
      exact this
    have hzero : (ψ₀ x - 1) * S = 0 := by linear_combination hshift
    rcases mul_eq_zero.1 hzero with h | h
    · exact absurd (by linear_combination h : ψ₀ x = 1) hx0
    · exact h

/-- **Poisson summation for finite abelian groups.**  For every subgroup `K` of
`G` and every function `f`, the sum of `f` over `K` is computed by the sum of
its Fourier transform over the annihilator of `K`. -/
theorem poisson_summation (K : AddSubgroup G) (f : G → ℂ) :
    (Nat.card G : ℂ) * ∑ k : ↥K, f (k : G)
      = (Nat.card ↥K : ℂ) * ∑ ψ : ↥(annihilator K), fourier f (ψ : AddChar G ℂ) := by
  classical
  have hswap : (∑ ψ : ↥(annihilator K), fourier f (ψ : AddChar G ℂ))
      = ∑ g : G, f g * (if -g ∈ K then (Nat.card ↥(annihilator K) : ℂ) else 0) := by
    have hexp : ∀ ψ : ↥(annihilator K), fourier f (ψ : AddChar G ℂ)
        = ∑ g : G, f g * (ψ : AddChar G ℂ) (-g) := fun ψ => fourier_apply f _
    rw [Finset.sum_congr rfl fun ψ _ => hexp ψ, Finset.sum_comm]
    refine Finset.sum_congr rfl fun g _ => ?_
    rw [← Finset.mul_sum, annihilator_sum K (-g)]
  have hneg : ∀ g : G, (-g ∈ K) ↔ (g ∈ K) := fun g => neg_mem_iff
  have hsum : (∑ ψ : ↥(annihilator K), fourier f (ψ : AddChar G ℂ))
      = (Nat.card ↥(annihilator K) : ℂ) * ∑ k : ↥K, f (k : G) := by
    rw [hswap]
    have hstep : ∀ g : G, f g * (if -g ∈ K then (Nat.card ↥(annihilator K) : ℂ) else 0)
        = if g ∈ K then (Nat.card ↥(annihilator K) : ℂ) * f g else 0 := by
      intro g
      by_cases hg : g ∈ K
      · rw [if_pos ((hneg g).2 hg), if_pos hg]; ring
      · rw [if_neg (fun h => hg ((hneg g).1 h)), if_neg hg, mul_zero]
    rw [Finset.sum_congr rfl fun g _ => hstep g, ← Finset.sum_filter,
      Finset.sum_subtype (p := fun g : G => g ∈ K)
        (Finset.univ.filter fun g : G => g ∈ K) (fun x => by simp)
        (fun g => (Nat.card ↥(annihilator K) : ℂ) * f g), ← Finset.mul_sum]
  rw [hsum, ← mul_assoc]
  have hcard : (Nat.card ↥K : ℂ) * (Nat.card ↥(annihilator K) : ℂ) = (Nat.card G : ℂ) := by
    have := card_annihilator K
    have hnat : Nat.card ↥K * Nat.card ↥(annihilator K) = Nat.card G := by
      rw [mul_comm]; exact this
    exact_mod_cast congrArg (fun n : ℕ => (n : ℂ)) hnat
  rw [hcard]

end FourierFunctor