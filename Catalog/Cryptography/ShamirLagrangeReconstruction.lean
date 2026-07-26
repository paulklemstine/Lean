import Mathlib

/-!
# Shamir Secret Sharing: Explicit Lagrange Reconstruction and Linear (MPC) Homomorphism

`ShamirSecretSharing` establishes reconstruction as a *uniqueness* statement: any `t`
distinct shares determine the degree-`< t` sharing polynomial, hence its secret `f.eval 0`.
That result is non-constructive — it says the secret is determined, but not *how* to
compute it from the shares.

This file closes that gap with the **explicit Lagrange reconstruction formula** and the
**linear-homomorphism** properties that make Shamir sharing the backbone of
secret-sharing-based secure multiparty computation (MPC).

We work with the Mathlib `Lagrange` API: a finite index set `s : Finset ι` of
participants, an injective-on-`s` evaluation-node map `v : ι → F` (participant `i` sits at
node `v i ≠ 0`), and a sharing polynomial `f : F[X]` of degree `< #s`.  The *share* of
participant `i` is `f.eval (v i)`.

## Main results

* `lagrangeCoeff` — the **reconstruction coefficient** `(Lagrange.basis s v i).eval 0`.
  It depends only on the nodes, *not* on `f` — the same fixed linear functional recovers
  the secret of every sharing polynomial.

* `shamir_reconstruct_at` — the **explicit interpolation formula**: for `f.degree < #s`
  and any point `z`, `f.eval z = ∑ i ∈ s, f.eval (v i) * (Lagrange.basis s v i).eval z`.

* `shamir_explicit_reconstruction` — the secret is the fixed linear combination of shares
  `f.eval 0 = ∑ i ∈ s, f.eval (v i) * lagrangeCoeff s v i`.  This is the operational
  reconstruction algorithm, the constructive companion of `shamir_reconstruction`.

* `sum_lagrangeCoeff_eq_one` — the reconstruction coefficients sum to `1` (over a nonempty
  participant set): reconstruction is an *affine/convex* combination of the shares.

* `shamir_reconstruct_additive` — **additive homomorphism (MPC addition).**  Applying the
  reconstruction functional to the participant-wise *sum* of two share vectors yields the
  *sum* of the two secrets.  Parties can add secrets locally on their shares.

* `shamir_reconstruct_smul` — **scalar homomorphism.**  Scaling every share by `a` scales
  the reconstructed secret by `a`.

* `shamir_reconstruct_linear_combination` — the general linear combination
  `a • shares(f) + b • shares(g)` reconstructs to `a * secret(f) + b * secret(g)`.

This bridges **Cryptography** ⟷ **Linear Algebra**: the reconstruction map is the linear
functional `(s → F) → F` dual to evaluation at `0`, and all MPC linearity is its linearity.
-/

namespace ShamirLagrangeReconstruction

open Polynomial Finset

variable {F : Type*} [Field F] {ι : Type*} [DecidableEq ι]
variable {s : Finset ι} {v : ι → F}

/-- The Shamir reconstruction coefficient of participant `i`: the value at the secret point
`0` of the `i`-th Lagrange basis polynomial.  Depends only on the nodes `v` over `s`. -/
def lagrangeCoeff (s : Finset ι) (v : ι → F) (i : ι) : F :=
  (Lagrange.basis s v i).eval 0

/-
**Explicit interpolation / reconstruction at an arbitrary point.**
A polynomial of degree `< #s` is the Lagrange combination of its values on the nodes:
`f.eval z = ∑ i ∈ s, f.eval (v i) * (Lagrange.basis s v i).eval z`.
-/
theorem shamir_reconstruct_at (hvs : Set.InjOn v s) {f : F[X]} (hf : f.degree < #s) (z : F) :
    f.eval z = ∑ i ∈ s, f.eval (v i) * (Lagrange.basis s v i).eval z := by
  convert congr_arg ( Polynomial.eval z ) ( Lagrange.eq_interpolate hvs hf ) using 1;
  simp +decide [ Lagrange.interpolate_apply, Polynomial.eval_finset_sum ]

/-
**Explicit secret reconstruction.**  The Shamir secret `f.eval 0` is the fixed linear
combination of the shares with the node-only reconstruction coefficients.
-/
theorem shamir_explicit_reconstruction (hvs : Set.InjOn v s) {f : F[X]} (hf : f.degree < #s) :
    f.eval 0 = ∑ i ∈ s, f.eval (v i) * lagrangeCoeff s v i := by
  convert shamir_reconstruct_at hvs hf 0 using 1

/-
The reconstruction coefficients sum to `1` over a nonempty participant set:
reconstruction is an affine combination of the shares.
-/
theorem sum_lagrangeCoeff_eq_one (hvs : Set.InjOn v s) (hs : s.Nonempty) :
    ∑ i ∈ s, lagrangeCoeff s v i = 1 := by
  convert congr_arg ( Polynomial.eval 0 ) ( Lagrange.sum_basis hvs hs ) using 1 ; simp +decide [ Polynomial.eval_finset_sum, Polynomial.eval_one, lagrangeCoeff ];
  norm_num

/-
**Additive homomorphism (the algebraic core of MPC addition).**  The reconstruction
functional applied to the participant-wise sum of two share vectors equals the sum of the
two reconstructed secrets.
-/
theorem shamir_reconstruct_additive (hvs : Set.InjOn v s) {f g : F[X]}
    (hf : f.degree < #s) (hg : g.degree < #s) :
    ∑ i ∈ s, (f.eval (v i) + g.eval (v i)) * lagrangeCoeff s v i = f.eval 0 + g.eval 0 := by
  simp_all +decide [ add_mul, Finset.sum_add_distrib ];
  rw [ ← shamir_explicit_reconstruction hvs hf, ← shamir_explicit_reconstruction hvs hg ]

/-
**Scalar homomorphism.**  Scaling every share by `a` scales the reconstructed secret
by `a`.
-/
theorem shamir_reconstruct_smul (hvs : Set.InjOn v s) {f : F[X]} (hf : f.degree < #s) (a : F) :
    ∑ i ∈ s, (a * f.eval (v i)) * lagrangeCoeff s v i = a * f.eval 0 := by
  rw [ shamir_explicit_reconstruction hvs hf, Finset.mul_sum _ _ _ ] ; congr ; ext ; ring

/-
**General linear combination.**  Any `F`-linear combination of two share vectors
reconstructs to the corresponding linear combination of the secrets — Shamir sharing is an
`F`-linear secret-sharing scheme.
-/
theorem shamir_reconstruct_linear_combination (hvs : Set.InjOn v s) {f g : F[X]}
    (hf : f.degree < #s) (hg : g.degree < #s) (a b : F) :
    ∑ i ∈ s, (a * f.eval (v i) + b * g.eval (v i)) * lagrangeCoeff s v i
      = a * f.eval 0 + b * g.eval 0 := by
  simp +decide only [add_mul, mul_assoc];
  rw [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.mul_sum _ _ _, ShamirLagrangeReconstruction.shamir_explicit_reconstruction hvs hf, ShamirLagrangeReconstruction.shamir_explicit_reconstruction hvs hg ]

/-
**Multiplicative reconstruction (BGW core).**  If the participant set is large enough
to hold the product polynomial (`(f * g).degree < #s`, e.g. `#s ≥ 2t-1` for `f, g` of
degree `< t`), then the product secret `f.eval 0 * g.eval 0` is reconstructed from the
participant-wise *products* of shares with the same Lagrange weights.  This is the
multiplicative complement of `shamir_reconstruct_additive` and the algebraic heart of
BGW-style multiparty multiplication.
-/
theorem shamir_reconstruct_mul (hvs : Set.InjOn v s) {f g : F[X]}
    (hfg : (f * g).degree < #s) :
    ∑ i ∈ s, (f.eval (v i) * g.eval (v i)) * lagrangeCoeff s v i = f.eval 0 * g.eval 0 := by
  convert shamir_explicit_reconstruction hvs hfg using 1;
  · exact Eq.symm ( by rw [ shamir_explicit_reconstruction hvs hfg ] ; simp +decide [ Polynomial.eval_mul ] );
  · rw [ ← Polynomial.eval_mul, ← shamir_explicit_reconstruction hvs hfg ]

end ShamirLagrangeReconstruction