/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Exponential-Convolution Ring of Counting Sequences

This file extends the combinatorial–categorical bridge of
`Catalog/Applications/CombinatorialSpecies.lean` and
`Catalog/Applications/SpeciesAnalyticBridge.lean`.

Those files established that the exponential generating function
`egf a = ∑ₙ (aₙ/n!) Xⁿ` is

* additive over the sum of species              (`egf_add`),
* multiplicative over the Day-convolution product (`egf_mul`, `egf_card_prodSpecies`),
* a *bijection* `(ℕ → ℚ) ≃ ℚ⟦X⟧` with explicit inverse `seqOf`  (`egfEquiv`),

i.e. a homomorphism for each operation *separately*.  This file promotes those scattered
identities into a single **structural** statement (Future Direction #4 of the species
program): the set of counting sequences, equipped with the **exponential (binomial)
convolution** `binConv` as multiplication and pointwise addition, is a genuine
`CommRing` `ConvSeq`, and the EGF is a `RingEquiv`

  `egfRingEquiv : ConvSeq ≃+* ℚ⟦X⟧`.

Bundling the bridge as a `RingEquiv` makes the full algebra of `map_mul`, `map_add`,
`map_one`, `map_pow`, `map_sum`, `mul_comm`, `mul_assoc`, distributivity, … available to
downstream species computations *for free*.  As payoff we read off, with no index
juggling, the commutative-semiring axioms of `binConv` (`binConv_comm`, `binConv_assoc`,
the unit laws, distributivity), the power law `egf (binConvPow a k) = (egf a) ^ k`
(the algebraic engine behind species composition / the exponential formula), and a
generalization of the linear-order EGF to *every* factorial-counted species.

## Main results
* `ConvSeq` / `egfRingEquiv`            — counting sequences form a `CommRing`; EGF is a ring iso.
* `ConvSeq.mul_seq`/`add_seq`/`one_seq` — the transported operations are exactly
                                          `binConv` / pointwise `+` / `binConvOne`.
* `binConv_comm`, `binConv_assoc`,
  `binConv_one_left`, `binConv_add`     — the exponential-convolution semiring axioms.
* `egf_binConvPow`                      — `egf` of the `k`-fold convolution is `(egf a) ^ k`.
* `Species.EGF_inv_one_sub_X_of_factorial`
                                        — every `n!`-counted species has EGF `1/(1-X)`.
-/
import Mathlib
import Applications.SpeciesAnalyticBridge

open scoped BigOperators
open PowerSeries Finset

namespace CombinatorialSpecies

noncomputable section

/-! ### The exponential-convolution ring `ConvSeq` -/

-- !-- Lab Notebook -- !--
-- Hypothesis: `egf_mul`/`egf_add`/`egf_binConvOne` say `egf` respects `binConv`, `+`, `1`
--   *separately*; together they should make counting sequences a `CommRing` with `egf` a
--   `RingEquiv`, transporting the ring structure of `ℚ⟦X⟧` across the bijection `egfEquiv`.
-- Result: `ConvSeq` (a one-field wrapper around `ℕ → ℚ`) carries `CommRing` via
--   `Equiv.commRing`, and `egfRingEquiv := equiv.ringEquiv` is the ring iso.  The transported
--   operations are *characterized* by `mul_seq = binConv`, `add_seq = (·+·)`, `one_seq = binConvOne`.
-- Insight: a `structure` wrapper (not a `def` synonym) is essential — `ℕ → ℚ` already has the
--   *pointwise* `Pi` ring, so a reducible synonym creates an instance diamond between the
--   pointwise and the convolution multiplications.  Wrapping kills the diamond.
-- Failure analysis: the first attempt used `def ConvSeq := ℕ → ℚ`; `egfRingEquiv` then failed
--   to elaborate (`Pi.instMul` vs the transported `Mul` not defeq).  Switching to a structure
--   and routing every characterization through `egf_injective` made all proofs one-liners.

/-- Counting sequences `ℕ → ℚ` viewed as carriers of the **exponential-convolution** ring.
A `structure` wrapper (rather than a `def` synonym) so the convolution product does not
collide with the pointwise `Pi` multiplication already present on `ℕ → ℚ`. -/
structure ConvSeq where
  /-- The underlying counting sequence. -/
  seq : ℕ → ℚ

namespace ConvSeq

/-- `ConvSeq` is trivially in bijection with raw counting sequences. -/
def equivSeq : ConvSeq ≃ (ℕ → ℚ) :=
  ⟨ConvSeq.seq, ConvSeq.mk, fun _ => rfl, fun _ => rfl⟩

/-- The EGF bijection seen on the wrapper `ConvSeq ≃ ℚ⟦X⟧`. -/
noncomputable def equiv : ConvSeq ≃ ℚ⟦X⟧ := equivSeq.trans egfEquiv

/-- **The exponential-convolution ring.** Counting sequences form a commutative ring under
pointwise addition and binomial convolution, obtained by transporting the ring structure of
`ℚ⟦X⟧` across the EGF bijection. -/
noncomputable instance : CommRing ConvSeq := equiv.commRing

/-- **The EGF bridge as a ring isomorphism.** The exponential generating function is a ring
isomorphism from the exponential-convolution ring of counting sequences to formal power
series over `ℚ`.  This is Future Direction #4 of the species program realized as a bundled
`RingEquiv`, unlocking `map_mul`, `map_add`, `map_one`, `map_pow`, `map_sum`, … downstream. -/
noncomputable def egfRingEquiv : ConvSeq ≃+* ℚ⟦X⟧ := equiv.ringEquiv

@[simp] lemma egfRingEquiv_apply (a : ConvSeq) : egfRingEquiv a = egf a.seq := rfl

-- !-- Transport each operation across `egfRingEquiv` (a ring hom) and undo with `egf_injective`. -- !--
/-- The transported product is exactly the binomial (exponential) convolution. -/
@[simp] lemma mul_seq (a b : ConvSeq) : (a * b).seq = binConv a.seq b.seq := by
  apply egf_injective
  have h : egf (a * b).seq = egf a.seq * egf b.seq := by
    simpa using map_mul egfRingEquiv a b
  rw [h, egf_mul]

/-- The transported addition is exactly pointwise addition of sequences. -/
@[simp] lemma add_seq (a b : ConvSeq) : (a + b).seq = fun n => a.seq n + b.seq n := by
  apply egf_injective
  have h := map_add egfRingEquiv a b
  simp only [egfRingEquiv_apply] at h
  rw [h, ← egf_add]

/-- The transported one is exactly the convolution unit `(1,0,0,…)`. -/
@[simp] lemma one_seq : (1 : ConvSeq).seq = binConvOne := by
  apply egf_injective
  have h := map_one egfRingEquiv
  simp only [egfRingEquiv_apply] at h
  rw [h, egf_binConvOne]

/-- The transported zero is the zero sequence. -/
@[simp] lemma zero_seq : (0 : ConvSeq).seq = fun _ => (0 : ℚ) := by
  apply egf_injective
  have h := map_zero egfRingEquiv
  simp only [egfRingEquiv_apply] at h
  rw [h, egf_zero]

end ConvSeq

/-! ### The exponential-convolution semiring axioms, read off for free -/

-- !-- Lab Notebook -- !--
-- Hypothesis: with `ConvSeq` a `CommRing` whose `*` is `binConv`, the classical (and otherwise
--   index-heavy) semiring laws of binomial convolution should be immediate `congrArg`s of the
--   ambient ring axioms.
-- Result: `binConv_comm`, `binConv_assoc`, `binConv_one_left/right`, `binConv_add` all drop out.
-- Insight: this is exactly the "structural payoff" promised by bundling the bridge — proofs that
--   would need `Finset.antidiagonal`/`Nat.choose` manipulation become `mul_comm`/`mul_assoc`.
-- Failure analysis: none; `congrArg ConvSeq.seq` + `simp [ConvSeq.mul_seq, …]` closes each.

/-- **Commutativity of exponential convolution.** -/
theorem binConv_comm (a b : ℕ → ℚ) : binConv a b = binConv b a := by
  have := congrArg ConvSeq.seq (mul_comm (ConvSeq.mk a) (ConvSeq.mk b))
  simpa using this

/-- **Associativity of exponential convolution.** -/
theorem binConv_assoc (a b c : ℕ → ℚ) :
    binConv (binConv a b) c = binConv a (binConv b c) := by
  have := congrArg ConvSeq.seq (mul_assoc (ConvSeq.mk a) (ConvSeq.mk b) (ConvSeq.mk c))
  simpa using this

/-- **Left unit law** for exponential convolution: `binConvOne` is a left identity. -/
theorem binConv_one_left (a : ℕ → ℚ) : binConv binConvOne a = a := by
  have := congrArg ConvSeq.seq (one_mul (ConvSeq.mk a))
  simpa only [ConvSeq.mul_seq, ConvSeq.one_seq] using this

/-- **Right unit law** for exponential convolution: `binConvOne` is a right identity. -/
theorem binConv_one_right (a : ℕ → ℚ) : binConv a binConvOne = a := by
  have := congrArg ConvSeq.seq (mul_one (ConvSeq.mk a))
  simpa only [ConvSeq.mul_seq, ConvSeq.one_seq] using this

/-- **Distributivity** of exponential convolution over pointwise addition. -/
theorem binConv_add (a b c : ℕ → ℚ) :
    binConv a (fun n => b n + c n) = fun n => binConv a b n + binConv a c n := by
  have := congrArg ConvSeq.seq (mul_add (ConvSeq.mk a) (ConvSeq.mk b) (ConvSeq.mk c))
  simpa using this

/-! ### The power law: `k`-fold convolution ↔ `k`-th power of the EGF -/

-- !-- Lab Notebook -- !--
-- Hypothesis: iterating the product gives `egf (a^{⋆k}) = (egf a)^k`, the algebraic core of the
--   species composition / exponential formula (Future Direction #1).
-- Result: a *computable* recursive `binConvPow` agrees with the ring power `(ConvSeq.mk a)^k`,
--   and `egf_binConvPow` reads `egf (binConvPow a k) = (egf a)^k` straight from `map_pow`.
-- Insight: keeping `binConvPow` computable (built from the decidable `binConv`) preserves the
--   constructive/`#eval` character while the ring iso supplies the closed-form EGF identity.
-- Failure analysis: a direct induction on the ring power was awkward; instead prove
--   `binConvPow_eq_pow` by induction (using `mul_seq`, `pow_succ`) and then transport once.

/-- The computable `k`-fold exponential convolution of a sequence, `a^{⋆k}`. -/
def binConvPow (a : ℕ → ℚ) : ℕ → (ℕ → ℚ)
  | 0 => binConvOne
  | k + 1 => binConv (binConvPow a k) a

/-- The recursive `binConvPow` agrees with the ring power in `ConvSeq`. -/
theorem binConvPow_eq_pow (a : ℕ → ℚ) (k : ℕ) :
    binConvPow a k = ((ConvSeq.mk a) ^ k).seq := by
  induction k with
  | zero => simp [binConvPow, pow_zero]
  | succ k ih => simp [binConvPow, pow_succ, ih, ConvSeq.mul_seq]

-- !-- `map_pow egfRingEquiv` gives `egf (a^k).seq = (egf a)^k`; rewrite via `binConvPow_eq_pow`. -- !--
/-- **Power law (composition engine).** The exponential generating function of the `k`-fold
binomial convolution `a^{⋆k}` is the `k`-th power of the EGF.  Equivalently, `egf` carries the
convolution power to the analytic power — the algebraic heart of species composition and the
exponential formula. -/
theorem egf_binConvPow (a : ℕ → ℚ) (k : ℕ) :
    egf (binConvPow a k) = (egf a) ^ k := by
  rw [binConvPow_eq_pow]
  have := map_pow ConvSeq.egfRingEquiv (ConvSeq.mk a) k
  simpa using this

/-! ### A named-EGF generalization: factorial counts give `1/(1-X)` -/

-- !-- Lab Notebook -- !--
-- Hypothesis: the `(1-X)·EGF = 1` law for linear orders depends only on the *count* `n!`, not
--   on the chosen structures, so it should generalize to every species with `coeffSeq = n!`.
-- Result: `Species.EGF_inv_one_sub_X_of_factorial`; the species of linear orders and the species
--   of permutations (same skeleton, count `n!`) are immediate instances (Future Direction #2/#3).
-- Insight: this is the enumerative shadow of categorical functoriality — the EGF sees only the
--   count, so equal counts force equal EGFs (cf. `Species.EGF_inj` from the sibling file).
-- Failure analysis: rewriting `coeffSeq` pointwise with the hypothesis under the `egf`/`mk`
--   wrapper needed `simp only [h]` before delegating to `egf_linearOrderSpecies`.

/-- **Factorial counts ⇒ EGF `1/(1-X)`.** Any species whose counting sequence is `n ↦ n!`
(linear orders, permutations, total orders, …) has exponential generating function the
geometric series, i.e. `(1 - X) · EGF = 1`.  This generalizes `egf_linearOrderSpecies` and is
the enumerative form of "the EGF is a count invariant": the EGF depends only on `coeffSeq`. -/
theorem Species.EGF_inv_one_sub_X_of_factorial (F : Species)
    (h : ∀ n, F.coeffSeq n = n.factorial) :
    (1 - PowerSeries.X) * F.EGF = 1 := by
  have : F.EGF = egf (fun n => (n.factorial : ℚ)) := by
    unfold Species.EGF
    congr 1
    funext n
    rw [h]
  rw [this]
  exact egf_linearOrderSpecies

/-- The species of linear orders is a factorial-counted species, hence has EGF `1/(1-X)`. -/
theorem egf_linearOrderSpecies_inv :
    (1 - PowerSeries.X) * linearOrderSpecies.EGF = 1 :=
  Species.EGF_inv_one_sub_X_of_factorial _ (by simp)

/-! ### Computational sanity checks -/

-- The convolution unit times the constant-one sequence returns the constant-one sequence,
-- up to the first few coefficients (constructive `decide`-style check).
example : binConv binConvOne (fun _ => (1 : ℚ)) 3 = (1 : ℚ) := by
  simp [binConv_one_left]

-- `a^{⋆0}` is the unit at coefficient 0.
example : binConvPow (fun _ => (1 : ℚ)) 0 0 = 1 := by
  simp [binConvPow, binConvOne]

end

end CombinatorialSpecies