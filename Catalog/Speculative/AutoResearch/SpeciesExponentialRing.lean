/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The exponential generating function as a ring isomorphism

This file deepens `Applications/CombinatorialSpecies.lean`.  There the exponential generating
function (EGF) transform `egf : (ℕ → ℚ) → ℚ⟦X⟧` was shown to send the disjoint-union (sum) of
combinatorial species to the sum of power series and the structural (Day-convolution) product of
species to the *product* of power series, the latter via the **binomial convolution** `binConv`.

Here we upgrade that dictionary from a pair of homomorphism *laws* to a full **isomorphism of
commutative rings**.  The carrier is the set of counting sequences `ℕ → ℚ` equipped with

* pointwise addition, and
* the binomial (exponential) convolution `binConv` as multiplication,
* with unit the Kronecker sequence `δ = (1, 0, 0, …)` (the species `1`, the empty structure).

This is the **Hurwitz / exponential-convolution ring** of combinatorial enumeration.  We prove
the EGF transform is a *bijection* (`egf_bijective`) with explicit inverse `egfInv f n = n! · [Xⁿ]f`,
and bundle everything into

  `egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧`,

the statement that **exponential generating functions are an isomorphism of commutative rings**
from the binomial-convolution ring of species onto formal power series over `ℚ`.

Two structural identities of species — *associativity* and the *unit law* of the product — then
drop out for free as analytic shadows of `mul_assoc` / `one_mul` in `ℚ⟦X⟧` (`binConv_assoc`,
`binConv_one_left`).  Finally `egfInv_exp` reconnects to the catalog (`CombinatorialSpecies`):
the inverse image of `exp` is the constant-one sequence — the counting sequence of the species of
sets `E` — so `egfRingEquiv.symm (exp ℚ)` *is* the species of sets.

This file is deliberately self-contained (it re-derives the base laws `egf_add`, `egf_mul`,
`egf_injective` of `CombinatorialSpecies` in the fresh namespace `SpeciesExpRing`) so that it can
be developed and built in isolation; mathematically it extends the catalog file.

## Main results
* `egf_bijective`     — the EGF transform is a bijection of `ℕ → ℚ` with `ℚ⟦X⟧`.
* `binConv_assoc`     — associativity of the binomial convolution (analytic shadow of `mul_assoc`).
* `binConv_one_left`  — the Kronecker sequence is a left unit for `binConv`.
* `ExpRing.commRing`  — the binomial-convolution ring structure on counting sequences.
* `ExpRing.egfRingEquiv` — **EGFs are a ring isomorphism** `ExpRing ≃+* ℚ⟦X⟧`.
* `egfInv_exp`        — the EGF-preimage of `exp` is the constant-one (species-of-sets) sequence.

-- !-- Lab Notebook -- !--
Hypothesis: The EGF dictionary of `CombinatorialSpecies.lean` (which records that `egf` is *additive*
  and *multiplicative* for the binomial convolution) should not merely be two homomorphism laws but
  the manifestation of a genuine *ring isomorphism* `(ℕ → ℚ, +, ⋆) ≃+* ℚ⟦X⟧`, with `egf` invertible
  via `egfInv f n = n! · [Xⁿ] f`.

Result: All headline results proved with no `sorry`.  `egf` is bijective; the binomial-convolution
  ring `ExpRing` is built by transporting the `CommRing` of `ℚ⟦X⟧` along the injective `egf`
  (`Function.Injective.commRing`); the bundled `egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧` is the isomorphism.
  Associativity and the unit law of the species product fall out as analytic shadows.

Insight: Once `egf` is recognised as an *isomorphism* of rings (not just a transform), every
  structural identity of species is forced by the corresponding identity in `ℚ⟦X⟧`.  The unit of the
  combinatorial product is the Kronecker sequence `δ` (species `1`), and `exp` pulls back to the
  species of sets — the exponential is *literally* the image of "one structure on every label set".

Failure analysis: To transport the ring structure along `egf`, the synonym `ExpRing` must carry
  `SMul ℕ`, `SMul ℤ`, `Pow _ ℕ`, `NatCast`, `IntCast`.  The powers/casts are defined through `egfInv`
  so that `egf` is definitionally compatible (`egf_rightInverse`); pointwise `n • a` requires
  `m • x = m * x` on `ℚ` for `egf_nsmul`/`egf_zsmul`.
-/
import Mathlib

open scoped BigOperators
open PowerSeries Finset

namespace SpeciesExpRing

noncomputable section

/-! ### Exponential generating functions and the binomial convolution (re-derived base layer) -/

/-- The exponential generating function of a counting sequence `a : ℕ → ℚ`, `∑ₙ (aₙ / n!) Xⁿ`. -/
def egf (a : ℕ → ℚ) : ℚ⟦X⟧ := PowerSeries.mk fun n => a n / n.factorial

@[simp] lemma coeff_egf (a : ℕ → ℚ) (n : ℕ) :
    PowerSeries.coeff (R := ℚ) n (egf a) = a n / n.factorial := by
  rw [egf, coeff_mk]

/-- The binomial (exponential) convolution `(a ⋆ b)ₙ = ∑_{i+j=n} C(n,i) aᵢ bⱼ`. -/
def binConv (a b : ℕ → ℚ) : ℕ → ℚ :=
  fun n => ∑ p ∈ Finset.antidiagonal n, (n.choose p.1 : ℚ) * a p.1 * b p.2

-- !-- Compare `coeff n` on both sides: it splits additively as `(aₙ + bₙ)/n!`. -- !--
/-- **Sum law.** The EGF of a pointwise sum is the sum of EGFs. -/
theorem egf_add (a b : ℕ → ℚ) : egf (fun n => a n + b n) = egf a + egf b := by
  unfold egf; ext n; norm_num; ring

-- !-- Compare `coeff n`: the Cauchy product over `antidiagonal n` matches the binomial
--     convolution divided by `n!`, via `Nat.cast_choose`. -- !--
/-- **Product law.** The EGF of the binomial convolution is the product of EGFs. -/
theorem egf_mul (a b : ℕ → ℚ) : egf (binConv a b) = egf a * egf b := by
  ext n
  simp +decide [egf, binConv, PowerSeries.coeff_mul]
  field_simp
  rw [Finset.mul_sum _ _ _]
  refine Finset.sum_congr rfl fun x hx => ?_
  rw [Nat.cast_choose]
  · rw [show x.2 = n - x.1 by
        rw [Finset.mem_antidiagonal] at hx; rw [eq_tsub_iff_add_eq_of_le] <;> linarith]
    ring
  · linarith [Finset.mem_antidiagonal.mp hx]

-- !-- `egf a = egf b` ⇒ `coeff n` equal ⇒ `aₙ/n! = bₙ/n!` ⇒ `aₙ = bₙ` (`n! ≠ 0` in `ℚ`). -- !--
/-- **Injectivity of the EGF transform.** -/
theorem egf_injective : Function.Injective egf := by
  intro a b h
  exact funext fun n => by
    simpa [eq_div_iff, Nat.factorial_ne_zero] using congr_arg (fun f => PowerSeries.coeff n f) h

-- !-- `egf (binConv a b) = egf a * egf b = egf b * egf a = egf (binConv b a)`, then `egf_injective`. -- !--
/-- **Commutativity of the binomial convolution**, as the analytic shadow of `mul_comm`. -/
theorem binConv_comm (a b : ℕ → ℚ) : binConv a b = binConv b a := by
  apply egf_injective
  rw [egf_mul, egf_mul, mul_comm]

/-! ### The Kronecker unit sequence and the inverse transform -/

/-- The Kronecker unit sequence `δ = (1, 0, 0, …)`: the counting sequence of the species `1`
(one structure on the empty set, none elsewhere).  It is the unit of the binomial convolution. -/
def deltaSeq : ℕ → ℚ := fun n => if n = 0 then 1 else 0

/-- The inverse of the EGF transform: `egfInv f n = n! · [Xⁿ] f` recovers the counting sequence
from a formal power series. -/
def egfInv (f : ℚ⟦X⟧) : ℕ → ℚ := fun n => PowerSeries.coeff n f * n.factorial

-- !-- `coeff 0 (egf δ) = 1`, and `coeff (n+1) (egf δ) = 0`; matches `coeff` of `1`. -- !--
/-- The EGF of the Kronecker unit sequence is `1`. -/
theorem egf_deltaSeq : egf deltaSeq = 1 := by
  ext (_ | n) <;> simp +decide [egf, deltaSeq]

-- !-- `coeff n (egf 0) = 0/n! = 0`. -- !--
/-- The EGF of the zero sequence is `0`. -/
theorem egf_zero : egf (fun _ => (0 : ℚ)) = 0 := by
  ext; aesop

-- !-- `coeff n`: `(-aₙ)/n! = -(aₙ/n!)`. -- !--
/-- The EGF transform is additive under negation. -/
theorem egf_neg (a : ℕ → ℚ) : egf (fun n => - a n) = - egf a := by
  ext; simp [div_eq_mul_inv]

-- !-- `coeff n`: `(aₙ - bₙ)/n! = aₙ/n! - bₙ/n!`. -- !--
/-- The EGF transform respects subtraction. -/
theorem egf_sub (a b : ℕ → ℚ) : egf (fun n => a n - b n) = egf a - egf b := by
  ext; simp +decide [sub_div]

-- !-- `coeff n`: `(m • aₙ)/n! = m • (aₙ/n!)` since `m • x = m * x` on `ℚ`. -- !--
/-- The EGF transform respects natural scalar multiplication. -/
theorem egf_nsmul (m : ℕ) (a : ℕ → ℚ) : egf (fun n => m • a n) = m • egf a := by
  ext n; simp +decide [egf]; ring_nf
  erw [PowerSeries.coeff_C_mul]; norm_num; ring

-- !-- Induct on `m : ℤ`; the base and successor steps reduce to `egf_zero`, `egf_add`,
--     `egf_nsmul`, `egf_sub`. -- !--
/-- The EGF transform respects integer scalar multiplication. -/
theorem egf_zsmul (m : ℤ) (a : ℕ → ℚ) : egf (fun n => m • a n) = m • egf a := by
  induction m using Int.induction_on <;> simp_all +decide [add_mul]
  · exact egf_zero
  · convert egf_add _ _ using 1; aesop
  · simp_all +decide [sub_mul, neg_mul]
    rw [← ‹(egf fun n => - (↑_ * a n)) = - (↑_ * egf a)›, egf_sub]

-- !-- `coeff n (egf (egfInv f)) = (coeff n f · n!)/n! = coeff n f`, since `n! ≠ 0`. -- !--
/-- `egfInv` is a right inverse of `egf`: every power series is the EGF of a counting sequence. -/
theorem egf_rightInverse (f : ℚ⟦X⟧) : egf (egfInv f) = f := by
  ext n
  unfold egf egfInv
  simp +decide [Nat.factorial_ne_zero]

-- !-- `egfInv (egf a) n = (coeff n (egf a))·n! = (aₙ/n!)·n! = aₙ`. -- !--
/-- `egfInv` is a left inverse of `egf`. -/
theorem egf_leftInverse (a : ℕ → ℚ) : egfInv (egf a) = a := by
  funext n
  unfold egfInv egf
  simp +decide [Nat.factorial_ne_zero]

/-- **Surjectivity of the EGF transform.** Every formal power series over `ℚ` arises as the EGF
of a (unique) counting sequence. -/
theorem egf_surjective : Function.Surjective egf :=
  fun f => ⟨egfInv f, egf_rightInverse f⟩

/-- **The EGF transform is a bijection** of counting sequences with formal power series. -/
theorem egf_bijective : Function.Bijective egf :=
  ⟨egf_injective, egf_surjective⟩

/-! ### Structural identities of the species product, as analytic shadows -/

-- !-- Apply `egf_injective`; both sides become `egf a * egf b * egf c` via `egf_mul` and `ring`. -- !--
/-- **Associativity of the binomial convolution** — the associativity of the structural product
of species — proved as the analytic shadow of `mul_assoc` in `ℚ⟦X⟧`. -/
theorem binConv_assoc (a b c : ℕ → ℚ) :
    binConv (binConv a b) c = binConv a (binConv b c) := by
  apply egf_injective
  rw [egf_mul, egf_mul, egf_mul, egf_mul, mul_assoc]

-- !-- Apply `egf_injective`; LHS = `egf δ * egf a = 1 * egf a = egf a` via `egf_deltaSeq`. -- !--
/-- **Left unit law** for the binomial convolution: the Kronecker sequence `δ` is a left unit. -/
theorem binConv_one_left (a : ℕ → ℚ) : binConv deltaSeq a = a := by
  apply egf_injective
  rw [egf_mul, egf_deltaSeq, one_mul]

-- !-- `binConv a δ = binConv δ a = a` via `binConv_comm` and `binConv_one_left`. -- !--
/-- **Right unit law** for the binomial convolution. -/
theorem binConv_one_right (a : ℕ → ℚ) : binConv a deltaSeq = a := by
  rw [binConv_comm]; exact binConv_one_left a

/-! ### The binomial-convolution (Hurwitz) ring of counting sequences -/

/-- The carrier of the **binomial-convolution ring** of counting sequences: as a type it is
`ℕ → ℚ`, but equipped with pointwise addition and the binomial convolution `binConv` as its
multiplication.  This is the algebraic home of Joyal's species under sum and product. -/
def ExpRing : Type := ℕ → ℚ

namespace ExpRing

instance : Add ExpRing := ⟨fun a b n => a n + b n⟩
instance : Mul ExpRing := ⟨binConv⟩
instance : Zero ExpRing := ⟨fun _ => 0⟩
instance : One ExpRing := ⟨deltaSeq⟩
instance : Neg ExpRing := ⟨fun a n => - a n⟩
instance : Sub ExpRing := ⟨fun a b n => a n - b n⟩
instance : SMul ℕ ExpRing := ⟨fun m a n => m • a n⟩
instance : SMul ℤ ExpRing := ⟨fun m a n => m • a n⟩
instance : Pow ExpRing ℕ := ⟨fun a m => (egfInv (egf a ^ m) : ℕ → ℚ)⟩
instance : NatCast ExpRing := ⟨fun m => egfInv ((m : ℚ⟦X⟧))⟩
instance : IntCast ExpRing := ⟨fun m => egfInv ((m : ℚ⟦X⟧))⟩

/-- The EGF transform viewed as a map out of the binomial-convolution ring. -/
def toPowerSeries : ExpRing → ℚ⟦X⟧ := egf

-- !-- Transport the `CommRing` of `ℚ⟦X⟧` back along the injective `egf` via
--     `Function.Injective.commRing`; the laws are exactly the `egf_*` homomorphism lemmas. -- !--
/-- **The binomial-convolution ring.** Counting sequences with pointwise sum and binomial
convolution form a commutative ring; the structure is transported along the EGF transform, whose
ring-homomorphism laws are exactly `egf_add` and `egf_mul`. -/
instance commRing : CommRing ExpRing :=
  Function.Injective.commRing (toPowerSeries : ExpRing → ℚ⟦X⟧) egf_injective
    egf_zero egf_deltaSeq
    (fun x y => egf_add x y) (fun x y => egf_mul x y)
    (fun x => egf_neg x) (fun x y => egf_sub x y)
    (fun m x => egf_nsmul m x) (fun m x => egf_zsmul m x)
    (fun _ _ => egf_rightInverse _) (fun _ => egf_rightInverse _) (fun _ => egf_rightInverse _)

-- !-- Package `toPowerSeries = egf` with inverse `egfInv` (both-sided by `egf_left/rightInverse`)
--     and homomorphism fields `egf_add`, `egf_mul`. -- !--
/-- **Exponential generating functions are a ring isomorphism.** The EGF transform is an
isomorphism of commutative rings from the binomial-convolution ring of counting sequences onto
the ring of formal power series over `ℚ`.  Addition of species corresponds to addition of EGFs;
the structural (Day-convolution) product of species corresponds to multiplication of EGFs. -/
def egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧ where
  toFun := toPowerSeries
  invFun := egfInv
  left_inv := egf_leftInverse
  right_inv := egf_rightInverse
  map_add' := egf_add
  map_mul' := egf_mul

@[simp] lemma egfRingEquiv_apply (a : ExpRing) : egfRingEquiv a = egf a := rfl

@[simp] lemma egfRingEquiv_symm_apply (f : ℚ⟦X⟧) : egfRingEquiv.symm f = egfInv f := rfl

end ExpRing

/-! ### Reconnection to the catalog: the species of sets is the EGF-preimage of `exp` -/

-- !-- `egfInv (exp ℚ) n = coeff n (exp ℚ) · n! = (1/n!)·n! = 1`, using `coeff_exp`. -- !--
/-- **The species of sets is the preimage of `exp`.** The inverse EGF transform sends the
exponential `exp ℚ` to the constant-one counting sequence — exactly the counting sequence of the
species of sets `E` (cf. `CombinatorialSpecies.EGF_setSpecies`). -/
theorem egfInv_exp : egfInv (PowerSeries.exp ℚ) = fun _ => (1 : ℚ) := by
  funext n; simp [egfInv, PowerSeries.coeff_exp]; field_simp

-- !-- Immediate from `egfRingEquiv_symm_apply` and `egfInv_exp`. -- !--
/-- The species-of-sets counting sequence is recovered from `exp` by the ring isomorphism:
`egfRingEquiv.symm (exp ℚ)` is the constant-one sequence. -/
theorem egfRingEquiv_symm_exp :
    ExpRing.egfRingEquiv.symm (PowerSeries.exp ℚ) = fun _ => (1 : ℚ) :=
  egfInv_exp

end

end SpeciesExpRing