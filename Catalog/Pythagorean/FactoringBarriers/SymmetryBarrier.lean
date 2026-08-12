import Mathlib

/-!
# Barrier II: the symmetry (group-theoretic) barrier

The modulus map `(p, q) ↦ p * q` is invariant under the transposition of the two
factors.  Consequently *any* quantity computed from `N` alone is a symmetric function
of the pair `(p, q)`, and no antisymmetric quantity (such as `p - q`, or "return the
first factor") can be a function of `N`.

The main results are:

* `FactoringBarriers.prime_pair_unique` : the unordered pair of prime factors is
  determined by the product (the only ambiguity is the transposition).
* `FactoringBarriers.computableFromProduct_iff_symmetric` : a *complete
  characterization* — a quantity `D p q` is computable from `N = p q` **iff** it is
  symmetric.  This is a sharp dichotomy: the symmetry barrier is not merely a
  necessary condition, it is exactly the obstruction.
* `FactoringBarriers.antisymmetric_not_computable` : a nonzero antisymmetric quantity
  is never computable from `N`; e.g. `p - q` and "first factor" are not.
* `FactoringBarriers.min_computable_from_product` : *sharpness in the other
  direction*.  The smaller prime **is** an (abstract, noncomputable) function of `N`.
  So the symmetry barrier is a well-definedness obstruction, not a hardness result;
  it kills the antisymmetric half of the information and nothing more.  Recording
  this boundary explicitly is what keeps the barrier honest.
-/

namespace FactoringBarriers

/-! ### Unique factorization for products of two primes -/

/-- If two products of primes agree, the pairs agree up to a transposition.  This is
the exact statement that the modulus determines the *unordered* pair of factors. -/
theorem prime_pair_unique {p q a b : ℕ} (hp : p.Prime) (ha : a.Prime)
    (hb : b.Prime) (h : p * q = a * b) : (p = a ∧ q = b) ∨ (p = b ∧ q = a) := by
  have hpab : p ∣ a * b := ⟨q, by rw [← h]⟩
  rcases (Nat.Prime.dvd_mul hp).mp hpab with h1 | h1
  · have hpa : p = a := (Nat.prime_dvd_prime_iff_eq hp ha).mp h1
    subst hpa
    exact Or.inl ⟨rfl, Nat.eq_of_mul_eq_mul_left hp.pos h⟩
  · have hpb : p = b := (Nat.prime_dvd_prime_iff_eq hp hb).mp h1
    subst hpb
    right
    refine ⟨rfl, ?_⟩
    have h' : p * q = a * p := h
    have : q * p = a * p := by rw [mul_comm q p]; exact h'
    exact Nat.eq_of_mul_eq_mul_right hp.pos this

/-! ### The symmetry dichotomy -/

/-- `D` is *computable from the product*: there is a function of `N = p q` alone that
returns `D p q` on every pair of primes. -/
def ComputableFromProduct {γ : Type*} (D : ℕ → ℕ → γ) : Prop :=
  ∃ G : ℕ → γ, ∀ p q : ℕ, p.Prime → q.Prime → G (p * q) = D p q

/-- **Symmetry barrier (necessity).**  Anything computable from the modulus is a
symmetric function of the two prime factors. -/
theorem symmetric_of_computableFromProduct {γ : Type*} {D : ℕ → ℕ → γ}
    (h : ComputableFromProduct D) :
    ∀ p q : ℕ, p.Prime → q.Prime → D p q = D q p := by
  obtain ⟨G, hG⟩ := h
  intro p q hp hq
  rw [← hG p q hp hq, ← hG q p hq hp, mul_comm]

/-- **Symmetry barrier (sufficiency).**  Conversely every symmetric quantity *is*
computable from the modulus: unique factorization means the modulus determines the
unordered pair, hence any symmetric quantity is a well-defined function of it. -/
theorem computableFromProduct_of_symmetric {γ : Type*} [Nonempty γ] {D : ℕ → ℕ → γ}
    (hsymm : ∀ p q : ℕ, p.Prime → q.Prime → D p q = D q p) :
    ComputableFromProduct D := by
  classical
  set P : ℕ → Prop := fun n => ∃ x : ℕ × ℕ, x.1.Prime ∧ x.2.Prime ∧ n = x.1 * x.2 with hP
  refine ⟨fun n => if h : P n then D (h.choose.1) (h.choose.2) else Classical.arbitrary γ, ?_⟩
  intro p q hp hq
  have hmem : P (p * q) := ⟨(p, q), hp, hq, rfl⟩
  show (if h : P (p * q) then D (h.choose.1) (h.choose.2) else Classical.arbitrary γ) = D p q
  rw [dif_pos hmem]
  obtain ⟨ha, hb, hab⟩ := hmem.choose_spec
  rcases prime_pair_unique ha hp hq hab.symm with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · rw [h1, h2]
  · rw [h1, h2]; exact hsymm q p hq hp

/-- **The symmetry dichotomy.**  A quantity attached to pairs of primes is computable
from their product if and only if it is symmetric.  Everything symmetric survives,
nothing antisymmetric does. -/
theorem computableFromProduct_iff_symmetric {γ : Type*} [Nonempty γ] (D : ℕ → ℕ → γ) :
    ComputableFromProduct D ↔ ∀ p q : ℕ, p.Prime → q.Prime → D p q = D q p :=
  ⟨symmetric_of_computableFromProduct, computableFromProduct_of_symmetric⟩

/-! ### Antisymmetric quantities are lost -/

/-- **No antisymmetric factoring witness.**  If `D` is antisymmetric (valued in an
additive group without `2`-torsion) and is nonzero on some pair of primes, it is not
computable from the modulus.

The `2`-torsion hypothesis is genuinely needed: over `ZMod 2` the antisymmetric
quantity `D p q = p + q` is also symmetric, so nothing is lost there. -/
theorem antisymmetric_not_computable {γ : Type*} [AddGroup γ] {D : ℕ → ℕ → γ}
    (htors : ∀ x : γ, x = -x → x = 0)
    (hanti : ∀ p q : ℕ, D q p = - D p q)
    {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : D p q ≠ 0) :
    ¬ ComputableFromProduct D := by
  intro h
  have hs := symmetric_of_computableFromProduct h p q hp hq
  rw [hanti p q] at hs
  exact hne (htors _ hs)

/-- Specialization to `ℤ`-valued differences: the *gap between the two prime factors*
is not a function of the modulus. -/
theorem prime_gap_not_computable :
    ¬ ComputableFromProduct (fun p q : ℕ => (p : ℤ) - (q : ℤ)) := by
  intro h
  have hs := symmetric_of_computableFromProduct h 2 3 Nat.prime_two Nat.prime_three
  norm_num at hs

/-- **No "first factor" extractor.**  There is no function of the modulus returning
the *left* factor of the presentation `N = p q`. -/
theorem first_factor_not_computable :
    ¬ ComputableFromProduct (fun p _ : ℕ => p) := by
  intro h
  have hs := symmetric_of_computableFromProduct h 2 3 Nat.prime_two Nat.prime_three
  norm_num at hs

/-! ### Sharpness: the symmetric half of the factor information survives -/

/-- **Sharpness of the symmetry barrier.**  The *smaller* prime factor is a symmetric
quantity, hence it is a genuine (if noncomputable) function of the modulus.  So the
symmetry barrier is an obstruction to well-definedness only: it forbids antisymmetric
witnesses and nothing more, and in particular it does **not** by itself imply that
factoring is hard. -/
theorem min_computable_from_product : ComputableFromProduct (fun p q : ℕ => min p q) :=
  computableFromProduct_of_symmetric (fun p q _ _ => Nat.min_comm p q)

/-- The same for the sum of the factors, i.e. `p + q` is recoverable from `N` in the
abstract sense (this is the classical fact that `N` determines `p + q`). -/
theorem sum_computable_from_product : ComputableFromProduct (fun p q : ℕ => p + q) :=
  computableFromProduct_of_symmetric (fun p q _ _ => Nat.add_comm p q)

/-! ### The abstract mechanism: invariance under a symmetry -/

/-- The general principle behind the barrier: if the data map `enc` is invariant under
a symmetry `σ` of the secret space, then every quantity computed from `enc` is
`σ`-invariant.  Taking `enc (p,q) = p*q` and `σ` the transposition gives Barrier II. -/
theorem invariant_of_factors_through {α β γ : Type*} (enc : α → β) (σ : α → α)
    (hσ : ∀ a, enc (σ a) = enc a) (F : β → γ) : ∀ a, F (enc (σ a)) = F (enc a) :=
  fun a => congrArg F (hσ a)

end FactoringBarriers