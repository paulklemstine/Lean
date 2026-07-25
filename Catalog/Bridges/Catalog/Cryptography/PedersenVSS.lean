import Mathlib

/-!
# Pedersen Verifiable Secret Sharing: Completeness, Homomorphism, and Perfect Hiding

`FeldmanVSS` formalizes Feldman's verifiable secret sharing, whose commitments are
**perfectly binding** (the commitment vector determines the polynomial) but only
**computationally hiding**.  Pedersen's VSS makes the opposite trade-off: it is
**perfectly (information-theoretically) hiding** and only computationally binding.  This
file formalizes the Pedersen variant and proves, as the headline result, that its
commitments leak *zero* information about the sharing polynomial.

Following the catalog's additive-group convention (cf. `FeldmanVSS`, `SchnorrIdentification`),
the prime-order group is modelled as a field `F` with two fixed generators `g` and `h`
(the discrete log of `h` w.r.t. `g` is unknown to the dealer).  Group exponentiation is
scalar multiplication.

* The dealer has a sharing polynomial `f : F[X]` (secret `f.eval 0`) and an independent
  **blinding** polynomial `f' : F[X]`.
* The Pedersen **commitment** to coefficient `j` is `Cⱼ = (f.coeff j)·g + (f'.coeff j)·h`
  (`pedersenCommit`).
* The **share** of the participant at point `x` is the pair `(f.eval x, f'.eval x)`.
* A claimed share `(s, s')` **verifies** iff `s·g + s'·h = ∑_{j<t} xʲ·Cⱼ`
  (`PedersenVerifies`).

## Main results

* `pedersen_commitment_eval` — the verification right-hand side equals
  `(f.eval x)·g + (f'.eval x)·h`.
* `pedersen_complete` — **completeness**: an honest dealer's shares always verify.
* `pedersen_commit_add` — **homomorphism**: Pedersen commitments add coefficient-wise, so
  sums of secrets are committed by sums of commitments.
* `pedersen_perfect_hiding` — **perfect hiding**: for *every* candidate sharing polynomial
  `f` there exists a blinding polynomial `f'` reproducing *any* given commitment vector
  (when `h ≠ 0`).  The commitments are therefore consistent with every secret.
* `pedersen_equivocation` — the sharp contrast with Feldman binding (`feldman_binding`):
  two *different* sharing polynomials can be committed to the *same* vector via suitable
  blindings, so the commitments alone never reveal which polynomial was shared.

This bridges **Cryptography** ⟷ **Algebra**: perfect hiding is the surjectivity of the
blinding map `f' ↦ (Pedersen commitments)`, dual to the injectivity that gives Feldman
binding.
-/

namespace PedersenVSS

open Polynomial Finset

variable {F : Type*} [Field F]

/-- The `j`-th Pedersen commitment: `(f.coeff j)·g + (f'.coeff j)·h`. -/
def pedersenCommit (g h : F) (f f' : F[X]) (j : ℕ) : F :=
  f.coeff j * g + f'.coeff j * h

/-- The verifier's acceptance predicate: a claimed share `(s, s')` at point `x` against the
published commitments `C : ℕ → F` with threshold `t`. -/
def PedersenVerifies (g h : F) (t : ℕ) (C : ℕ → F) (x s s' : F) : Prop :=
  s * g + s' * h = ∑ j ∈ Finset.range t, x ^ j * C j

/-
The homomorphic combination of the Pedersen commitments reproduces the commitment
`(f.eval x)·g + (f'.eval x)·h` of the share.
-/
theorem pedersen_commitment_eval (g h : F) (t : ℕ) (f f' : F[X])
    (hf : f.natDegree < t) (hf' : f'.natDegree < t) (x : F) :
    ∑ j ∈ Finset.range t, x ^ j * pedersenCommit g h f f' j
      = (f.eval x) * g + (f'.eval x) * h := by
  simp +decide only [pedersenCommit];
  simp +decide [ mul_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, Polynomial.eval_eq_sum_range' ( show f.natDegree < t from hf ), Polynomial.eval_eq_sum_range' ( show f'.natDegree < t from hf' ) ]

/-
**Completeness.**  An honest dealer's share `(f.eval x, f'.eval x)` always verifies.
-/
theorem pedersen_complete (g h : F) (t : ℕ) (f f' : F[X])
    (hf : f.natDegree < t) (hf' : f'.natDegree < t) (x : F) :
    PedersenVerifies g h t (pedersenCommit g h f f') x (f.eval x) (f'.eval x) := by
  exact pedersen_commitment_eval g h t f f' hf hf' x |> Eq.symm

/-
**Homomorphism.**  Pedersen commitments add coefficient-wise: committing the sum of two
sharing/blinding polynomial pairs equals the sum of the commitments.
-/
theorem pedersen_commit_add (g h : F) (f₁ f₁' f₂ f₂' : F[X]) (j : ℕ) :
    pedersenCommit g h (f₁ + f₂) (f₁' + f₂') j
      = pedersenCommit g h f₁ f₁' j + pedersenCommit g h f₂ f₂' j := by
  unfold pedersenCommit; rw [ Polynomial.coeff_add, Polynomial.coeff_add ] ; ring;

/-
**Perfect hiding.**  When `h ≠ 0`, for *every* candidate sharing polynomial `f` and
*every* commitment vector `C`, there is a blinding polynomial `f'` whose Pedersen
commitments equal `C` on `range t`.  Thus the published commitments are equally consistent
with every sharing polynomial: they carry no information about the secret.
-/
theorem pedersen_perfect_hiding (g h : F) (hh : h ≠ 0) (t : ℕ) (C : ℕ → F) (f : F[X]) :
    ∃ f' : F[X], ∀ j ∈ Finset.range t, pedersenCommit g h f f' j = C j := by
  -- Construct the blinding polynomial explicitly: $f' := \sum_{j=0}^{t-1} \text{monomial } j ((C j - f.coeff j * g) / h)$.
  use ∑ j ∈ Finset.range t, Polynomial.monomial j ((C j - Polynomial.coeff f j * g) / h);
  intro j hj
  simp [pedersenCommit, Polynomial.coeff_sum, Polynomial.coeff_monomial];
  rw [ if_pos ( Finset.mem_range.mp hj ), div_mul_cancel₀ _ hh, add_sub_cancel ]

/-
**Equivocation (contrast with `feldman_binding`).**  When `h ≠ 0`, any two sharing
polynomials `f₁` and `f₂` can be committed to the *same* commitment vector (on `range t`)
via appropriate blinding polynomials.  Unlike Feldman commitments, Pedersen commitments do
not bind the dealer to a single polynomial — which is exactly what makes them perfectly
hiding.
-/
theorem pedersen_equivocation (g h : F) (hh : h ≠ 0) (t : ℕ) (f₁ f₂ : F[X]) :
    ∃ f₁' f₂' : F[X], ∀ j ∈ Finset.range t,
      pedersenCommit g h f₁ f₁' j = pedersenCommit g h f₂ f₂' j := by
  refine' ⟨ 0, ∑ j ∈ Finset.range t, Polynomial.monomial j ( ( f₁.coeff j * g - f₂.coeff j * g ) / h ), fun j hj => _ ⟩;
  simp_all +decide [ pedersenCommit, Polynomial.coeff_sum, Polynomial.coeff_monomial ]

end PedersenVSS