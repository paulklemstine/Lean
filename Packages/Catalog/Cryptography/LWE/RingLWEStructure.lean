/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.LWE.DualRegev

/-!
# Ring-LWE: the Negacyclic Ring, its Ring Laws, and LPR Decryption Correctness

The Ring-LWE problem of Lyubashevsky–Peikert–Regev lives in the *negacyclic*
ring `R = ℤ[X]/(Xⁿ + 1)`.  Cryptographic implementations never manipulate
polynomials: they manipulate coefficient vectors in `ℤⁿ` and multiply them with
the **negacyclic convolution**

  `(f ⊛ g)_k = ∑_{i+j=k} f_i g_j − ∑_{i+j=n+k} f_i g_j`.

This module makes that identification a theorem rather than a convention, and
then uses it to prove correctness of Ring-LWE (LPR) encryption.

## What is proved

* `RingLWEStruct.twist_sum` — the combinatorial heart: for any element `a` of a
  commutative ring with `aⁿ = −1`, the twisted indicator row sums to `aⁱ·aʲ`.
* `RingLWEStruct.embed_negaConv` — the **structure theorem**: the coefficient
  embedding `f ↦ ∑ fᵢ aⁱ` turns negacyclic convolution into ring multiplication,
  in *every* commutative ring containing an element `a` with `aⁿ = −1`.
* `RingLWEStruct.embed_injective` — over the universal such ring
  `ℤ[X]/(Xⁿ+1)`, the coefficient embedding is injective (it is a power basis).
* `RingLWEStruct.negaConv_comm`, `negaConv_assoc`, `negaConv_add_right`,
  `negaConv_one` — consequently the ring laws for `⊛` hold on the nose.  These
  are *derived*, not assumed.
* `RingLWEStruct.abs_negaConv_le` — the **expansion factor** of `Xⁿ+1`: the
  convolution of vectors with `‖f‖_∞ ≤ A`, `‖g‖_∞ ≤ B` satisfies
  `‖f ⊛ g‖_∞ ≤ n·A·B`.  (The naive double-sum bound would give `n²AB`; the sharp
  factor `n` comes from the fact that each row of the twist tensor has exactly
  one nonzero entry.)
* `RingLWEStruct.map_negaConv` — convolution commutes with any ring
  homomorphism, in particular with reduction modulo `q`.
* `RingLWEStruct.rlwe_residual` — the exact LPR decryption residual
  `c₁ − s ⊛ c₀ = e ⊛ r + e₂ − s ⊛ e₁ + encode(μ)`.
* `RingLWEStruct.rlwe_decrypt_correct` — coefficientwise decryption
  correctness under an explicit parameter condition
  `4·(n·B_e·B_r + B₂ + n·B_s·B₁) < q`.
* `RingLWEStruct.embed_surjective` / `embed_bijective` /
  `negaConv_isomorphism` — the coefficient model is not only faithful but
  *complete*: `(Fin n → ℤ, +, ⊛, δ₀)` is isomorphic to `ℤ[X]/(Xⁿ+1)`.

## References

* Lyubashevsky, Peikert, Regev, "On Ideal Lattices and Learning with Errors over
  Rings", EUROCRYPT 2010 / JACM 2013.
-/

open Polynomial Finset BigOperators

noncomputable section

namespace RingLWEStruct

/-! ## Section 1: The twist tensor of `Xⁿ + 1` -/

/-- The structure constants of `ℤ[X]/(Xⁿ+1)` in the monomial basis:
`twist i j k = 1` if `i + j = k`, `-1` if `i + j = n + k`, and `0` otherwise. -/
def twist (n : ℕ) (i j k : Fin n) : ℤ :=
  if (i : ℕ) + (j : ℕ) = (k : ℕ) then 1
  else if (i : ℕ) + (j : ℕ) = n + (k : ℕ) then -1 else 0

/-- **Row sum of the twist tensor.**  In any commutative ring containing an
element `a` with `aⁿ = −1`, the `(i, j)` row of the twist tensor reproduces the
product `aⁱ·aʲ`.  This single identity is what makes negacyclic convolution the
correct multiplication rule. -/
theorem twist_sum {R : Type*} [CommRing R] {n : ℕ} (a : R) (ha : a ^ n = -1) (i j : Fin n) :
    ∑ k : Fin n, ((twist n i j k : ℤ) : R) * a ^ (k : ℕ) = a ^ (i : ℕ) * a ^ (j : ℕ) := by
  have hn : 0 < n := i.pos
  rcases lt_or_ge ((i : ℕ) + (j : ℕ)) n with hlt | hge
  · rw [Finset.sum_eq_single (⟨(i : ℕ) + (j : ℕ), hlt⟩ : Fin n)]
    · simp [twist, ← pow_add]
    · intro b _ hb
      have hbv : (b : ℕ) ≠ (i : ℕ) + (j : ℕ) := fun hc => hb (Fin.ext hc)
      have h1 : ¬ ((i : ℕ) + (j : ℕ) = (b : ℕ)) := fun hc => hbv hc.symm
      have h2 : ¬ ((i : ℕ) + (j : ℕ) = n + (b : ℕ)) := by omega
      simp [twist, h1, h2]
    · intro hcon; exact absurd (Finset.mem_univ _) hcon
  · obtain ⟨m, hm, hmlt⟩ : ∃ m, (i : ℕ) + (j : ℕ) = n + m ∧ m < n :=
      ⟨(i : ℕ) + (j : ℕ) - n, by omega, by omega⟩
    rw [Finset.sum_eq_single (⟨m, hmlt⟩ : Fin n)]
    · have ht : twist n i j (⟨m, hmlt⟩ : Fin n) = -1 := by
        simp only [twist]
        rw [if_neg (by omega), if_pos (by omega)]
      rw [ht]
      push_cast
      rw [← pow_add, hm, pow_add, ha]
    · intro b _ hb
      have hbv : (b : ℕ) ≠ m := fun hc => hb (Fin.ext hc)
      have h1 : ¬ ((i : ℕ) + (j : ℕ) = (b : ℕ)) := by omega
      have h2 : ¬ ((i : ℕ) + (j : ℕ) = n + (b : ℕ)) := by omega
      simp [twist, h1, h2]
    · intro hcon; exact absurd (Finset.mem_univ _) hcon

/-! ## Section 2: Negacyclic convolution -/

/-- **Negacyclic convolution** of coefficient vectors over an arbitrary
commutative ring: the multiplication rule of `R[X]/(Xⁿ+1)` in the monomial
basis. -/
def negaConv {R : Type*} [CommRing R] {n : ℕ} (f g : Fin n → R) : Fin n → R :=
  fun k => ∑ i, ∑ j, ((twist n i j k : ℤ) : R) * (f i * g j)

/-- Negacyclic convolution commutes with every ring homomorphism; in particular
with reduction modulo `q`. -/
theorem map_negaConv {R S : Type*} [CommRing R] [CommRing S] {n : ℕ}
    (φ : R →+* S) (f g : Fin n → R) (k : Fin n) :
    φ (negaConv f g k) = negaConv (fun i => φ (f i)) (fun i => φ (g i)) k := by
  simp [negaConv, map_sum, map_mul]

/-- The coefficient embedding `f ↦ ∑ fᵢ aⁱ`. -/
def embed {R : Type*} [CommRing R] {n : ℕ} (a : R) (f : Fin n → ℤ) : R :=
  ∑ i, ((f i : ℤ) : R) * a ^ (i : ℕ)

theorem embed_add {R : Type*} [CommRing R] {n : ℕ} (a : R) (f g : Fin n → ℤ) :
    embed a (f + g) = embed a f + embed a g := by
  simp only [embed, Pi.add_apply, Int.cast_add, add_mul]
  rw [Finset.sum_add_distrib]

theorem embed_sub {R : Type*} [CommRing R] {n : ℕ} (a : R) (f g : Fin n → ℤ) :
    embed a (f - g) = embed a f - embed a g := by
  simp only [embed, Pi.sub_apply, Int.cast_sub, sub_mul]
  rw [Finset.sum_sub_distrib]

/-- **Structure theorem.**  The coefficient embedding carries negacyclic
convolution to ring multiplication, in every commutative ring with an element
`a` satisfying `aⁿ = −1`. -/
theorem embed_negaConv {R : Type*} [CommRing R] {n : ℕ} (a : R) (ha : a ^ n = -1)
    (f g : Fin n → ℤ) : embed a (negaConv f g) = embed a f * embed a g := by
  calc embed a (negaConv f g)
      = ∑ k : Fin n, ∑ i : Fin n, ∑ j : Fin n,
          ((twist n i j k : ℤ) : R) * ((f i : ℤ) : R) * ((g j : ℤ) : R) * a ^ (k : ℕ) := by
        simp only [embed, negaConv]
        refine Finset.sum_congr rfl fun k _ => ?_
        push_cast
        rw [Finset.sum_mul]
        refine Finset.sum_congr rfl fun i _ => ?_
        rw [Finset.sum_mul]
        refine Finset.sum_congr rfl fun j _ => ?_
        ring
    _ = ∑ i : Fin n, ∑ j : Fin n, ∑ k : Fin n,
          ((twist n i j k : ℤ) : R) * ((f i : ℤ) : R) * ((g j : ℤ) : R) * a ^ (k : ℕ) := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun i _ => Finset.sum_comm
    _ = ∑ i : Fin n, ∑ j : Fin n,
          (((f i : ℤ) : R) * a ^ (i : ℕ)) * (((g j : ℤ) : R) * a ^ (j : ℕ)) := by
        refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
        have : ∑ k : Fin n, ((twist n i j k : ℤ) : R) * ((f i : ℤ) : R) *
            ((g j : ℤ) : R) * a ^ (k : ℕ)
            = (((f i : ℤ) : R) * ((g j : ℤ) : R)) *
              ∑ k : Fin n, ((twist n i j k : ℤ) : R) * a ^ (k : ℕ) := by
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun k _ => by ring
        rw [this, twist_sum a ha i j]
        ring
    _ = embed a f * embed a g := by
        simp only [embed]
        rw [Finset.sum_mul_sum]

/-! ## Section 3: The universal negacyclic ring `ℤ[X]/(Xⁿ+1)` -/

/-- The negacyclic polynomial `Xⁿ + 1`. -/
abbrev negaPoly (n : ℕ) : ℤ[X] := X ^ n + 1

theorem negaPoly_monic (n : ℕ) (hn : n ≠ 0) : (negaPoly n).Monic := by
  simpa [negaPoly] using monic_X_pow_add_C (1 : ℤ) hn

theorem negaPoly_natDegree (n : ℕ) : (negaPoly n).natDegree = n := by
  have h : (negaPoly n) = X ^ n + C 1 := by simp [negaPoly]
  rw [h, natDegree_X_pow_add_C]

/-- The negacyclic ring `ℤ[X]/(Xⁿ+1)`. -/
abbrev NegaRing (n : ℕ) := AdjoinRoot (negaPoly n)

/-- The image of `X`: a primitive `2n`-th root of unity in `ℤ[X]/(Xⁿ+1)`. -/
def zeta (n : ℕ) : NegaRing n := AdjoinRoot.root _

/-- The defining relation `ζⁿ = −1`. -/
theorem zeta_pow (n : ℕ) : (zeta n) ^ n = -1 := by
  have h : (AdjoinRoot.mk (negaPoly n)) (negaPoly n) = 0 := AdjoinRoot.mk_self
  simp only [negaPoly, map_add, map_pow, AdjoinRoot.mk_X, map_one] at h
  have h2 : (AdjoinRoot.root (negaPoly n)) ^ n = -1 := by linear_combination h
  simpa [zeta] using h2

/-- **The coefficient embedding into `ℤ[X]/(Xⁿ+1)` is injective.**  Monomials
`1, ζ, …, ζⁿ⁻¹` form a power basis, so a coefficient vector is determined by the
ring element it represents.  This faithfulness is what lets us *derive* the ring
laws for negacyclic convolution instead of postulating them. -/
theorem embed_injective (n : ℕ) (hn : n ≠ 0) :
    Function.Injective (embed (zeta n) : (Fin n → ℤ) → NegaRing n) := by
  have hd : (AdjoinRoot.powerBasis' (negaPoly_monic n hn)).dim = n := by
    rw [AdjoinRoot.powerBasis'_dim, negaPoly_natDegree]
  set pb := AdjoinRoot.powerBasis' (negaPoly_monic n hn) with hpb
  let b : Module.Basis (Fin n) ℤ (NegaRing n) := pb.basis.reindex (finCongr hd)
  have hb : ∀ i : Fin n, b i = (zeta n) ^ (i : ℕ) := by
    intro i
    simp [b, Module.Basis.reindex_apply, PowerBasis.coe_basis, hpb,
      AdjoinRoot.powerBasis'_gen, zeta]
  intro f g hfg
  funext i
  have hzero : ∑ i, (f i - g i) • b i = 0 := by
    have h1 : ∑ i, (f i - g i) • b i = embed (zeta n) f - embed (zeta n) g := by
      simp only [hb, sub_smul, embed, zsmul_eq_mul]
      rw [Finset.sum_sub_distrib]
    rw [h1, hfg, sub_self]
  have hfin := Fintype.linearIndependent_iff.mp b.linearIndependent
    (fun i => f i - g i) hzero i
  omega

/-! ## Section 4: The ring laws for negacyclic convolution, derived -/

variable {n : ℕ}

/-- Faithfulness criterion: two integer coefficient vectors are equal iff their
images in `ℤ[X]/(Xⁿ+1)` agree. -/
theorem eq_of_embed_eq (hn : n ≠ 0) {f g : Fin n → ℤ}
    (h : embed (zeta n) f = embed (zeta n) g) : f = g :=
  embed_injective n hn h

/-- **Commutativity** of negacyclic convolution. -/
theorem negaConv_comm (hn : n ≠ 0) (f g : Fin n → ℤ) : negaConv f g = negaConv g f := by
  refine eq_of_embed_eq hn ?_
  rw [embed_negaConv _ (zeta_pow n), embed_negaConv _ (zeta_pow n), mul_comm]

/-- **Associativity** of negacyclic convolution. -/
theorem negaConv_assoc (hn : n ≠ 0) (f g h : Fin n → ℤ) :
    negaConv (negaConv f g) h = negaConv f (negaConv g h) := by
  refine eq_of_embed_eq hn ?_
  rw [embed_negaConv _ (zeta_pow n), embed_negaConv _ (zeta_pow n),
    embed_negaConv _ (zeta_pow n), embed_negaConv _ (zeta_pow n), mul_assoc]

/-- **Right distributivity** of negacyclic convolution over addition. -/
theorem negaConv_add_right (f g h : Fin n → ℤ) :
    negaConv f (g + h) = negaConv f g + negaConv f h := by
  funext k
  simp only [negaConv, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  ring

/-- **Left distributivity** of negacyclic convolution over addition. -/
theorem negaConv_add_left (f g h : Fin n → ℤ) :
    negaConv (f + g) h = negaConv f h + negaConv g h := by
  funext k
  simp only [negaConv, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  ring

/-- Negacyclic convolution respects subtraction in its right argument. -/
theorem negaConv_sub_right (f g h : Fin n → ℤ) :
    negaConv f (g - h) = negaConv f g - negaConv f h := by
  funext k
  simp only [negaConv, Pi.sub_apply]
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  ring

/-! ## Section 5: The expansion factor of `Xⁿ + 1` -/

/-- Each row of the twist tensor has at most one nonzero entry, so the inner
convolution sum is a single (signed) coefficient and inherits its bound. -/
theorem abs_twist_row_le {n : ℕ} (g : Fin n → ℤ) (B : ℤ) (hg : ∀ j, |g j| ≤ B)
    (i k : Fin n) : |∑ j, twist n i j k * g j| ≤ B := by
  rcases le_or_gt (i : ℕ) (k : ℕ) with hik | hik
  · have hlt : (k : ℕ) - (i : ℕ) < n := by omega
    rw [Finset.sum_eq_single (⟨(k : ℕ) - (i : ℕ), hlt⟩ : Fin n)]
    · have ht : twist n i (⟨(k : ℕ) - (i : ℕ), hlt⟩ : Fin n) k = 1 := by
        simp only [twist]
        rw [if_pos (by omega)]
      rw [ht, one_mul]
      exact hg _
    · intro b _ hb
      have hbv : (b : ℕ) ≠ (k : ℕ) - (i : ℕ) := fun hc => hb (Fin.ext hc)
      have h1 : ¬ ((i : ℕ) + (b : ℕ) = (k : ℕ)) := by omega
      have h2 : ¬ ((i : ℕ) + (b : ℕ) = n + (k : ℕ)) := by omega
      simp [twist, h1, h2]
    · intro hcon; exact absurd (Finset.mem_univ _) hcon
  · have hlt : n + (k : ℕ) - (i : ℕ) < n := by omega
    rw [Finset.sum_eq_single (⟨n + (k : ℕ) - (i : ℕ), hlt⟩ : Fin n)]
    · have ht : twist n i (⟨n + (k : ℕ) - (i : ℕ), hlt⟩ : Fin n) k = -1 := by
        simp only [twist]
        rw [if_neg (by omega), if_pos (by omega)]
      rw [ht]
      have := hg (⟨n + (k : ℕ) - (i : ℕ), hlt⟩ : Fin n)
      rw [show (-1 : ℤ) * g (⟨n + (k : ℕ) - (i : ℕ), hlt⟩ : Fin n)
        = -(g (⟨n + (k : ℕ) - (i : ℕ), hlt⟩ : Fin n)) by ring, abs_neg]
      exact this
    · intro b _ hb
      have hbv : (b : ℕ) ≠ n + (k : ℕ) - (i : ℕ) := fun hc => hb (Fin.ext hc)
      have h1 : ¬ ((i : ℕ) + (b : ℕ) = (k : ℕ)) := by omega
      have h2 : ¬ ((i : ℕ) + (b : ℕ) = n + (k : ℕ)) := by omega
      simp [twist, h1, h2]
    · intro hcon; exact absurd (Finset.mem_univ _) hcon

/-- **Expansion factor of the negacyclic ring.**  If `‖f‖_∞ ≤ A` and
`‖g‖_∞ ≤ B` then `‖f ⊛ g‖_∞ ≤ n·A·B`.  The factor is `n`, not `n²`: each row of
the twist tensor contributes a single term. -/
theorem abs_negaConv_le {n : ℕ} (f g : Fin n → ℤ) (A B : ℤ) (hA : 0 ≤ A)
    (hf : ∀ i, |f i| ≤ A) (hg : ∀ j, |g j| ≤ B) (k : Fin n) :
    |negaConv f g k| ≤ n * (A * B) := by
  have hrow : negaConv f g k = ∑ i, f i * (∑ j, twist n i j k * g j) := by
    simp only [negaConv]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by push_cast; ring
  rw [hrow]
  calc |∑ i, f i * (∑ j, twist n i j k * g j)|
      ≤ ∑ i, |f i * (∑ j, twist n i j k * g j)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin n, A * B := by
        refine Finset.sum_le_sum fun i _ => ?_
        rw [abs_mul]
        exact mul_le_mul (hf i) (abs_twist_row_le g B hg i k) (abs_nonneg _) hA
    _ = n * (A * B) := by simp [Finset.sum_const]

/-! ## Section 6: Ring-LWE (LPR) encryption and decryption -/

variable {q : ℕ}

/-- Coefficientwise reduction of an integer coefficient vector modulo `q`. -/
def toZqVec (q : ℕ) {n : ℕ} (v : Fin n → ℤ) : Fin n → ZMod q := fun i => ((v i : ℤ) : ZMod q)

/-- Reduction modulo `q` intertwines the two negacyclic convolutions. -/
theorem toZqVec_negaConv (q : ℕ) {n : ℕ} (f g : Fin n → ℤ) :
    toZqVec q (negaConv f g) = negaConv (toZqVec q f) (toZqVec q g) := by
  funext k
  simpa [toZqVec] using map_negaConv (Int.castRingHom (ZMod q)) f g k

theorem toZqVec_add (q : ℕ) {n : ℕ} (f g : Fin n → ℤ) :
    toZqVec q (f + g) = toZqVec q f + toZqVec q g := by
  funext k; simp [toZqVec]

theorem toZqVec_sub (q : ℕ) {n : ℕ} (f g : Fin n → ℤ) :
    toZqVec q (f - g) = toZqVec q f - toZqVec q g := by
  funext k; simp [toZqVec]

/-- **Ring-LWE public key**: `b = a ⊛ s + e`. -/
def rlwePubKey (a s e : Fin n → ℤ) : Fin n → ℤ := negaConv a s + e

/-- **Ring-LWE ciphertext, first component (integer lift)**: `c₀ = a ⊛ r + e₁`. -/
def rlweCt0 (a r e1 : Fin n → ℤ) : Fin n → ℤ := negaConv a r + e1

/-- **Ring-LWE ciphertext noise part of the second component (integer lift)**:
`b ⊛ r + e₂`. -/
def rlweCt1Noise (b r e2 : Fin n → ℤ) : Fin n → ℤ := negaConv b r + e2

/-- The aggregated Ring-LWE decryption noise `e ⊛ r + e₂ − s ⊛ e₁`. -/
def rlweResidualNoise (s e r e1 e2 : Fin n → ℤ) : Fin n → ℤ :=
  negaConv e r + e2 - negaConv s e1

/-- **Exact Ring-LWE decryption residual (integer form).**  Subtracting
`s ⊛ c₀` from the noise part of `c₁` leaves *exactly* the aggregated noise
`e ⊛ r + e₂ − s ⊛ e₁`.  Every ring law used here was derived in Section 4 from
faithfulness of the coefficient embedding. -/
theorem rlwe_residual (hn : n ≠ 0) (a s e r e1 e2 : Fin n → ℤ) :
    rlweCt1Noise (rlwePubKey a s e) r e2 - negaConv s (rlweCt0 a r e1)
      = rlweResidualNoise s e r e1 e2 := by
  simp only [rlweCt1Noise, rlwePubKey, rlweCt0, rlweResidualNoise]
  rw [negaConv_add_left, negaConv_add_right]
  have hkey : negaConv (negaConv a s) r = negaConv s (negaConv a r) := by
    rw [← negaConv_assoc hn s a r, negaConv_comm hn s a]
  rw [hkey]
  abel

/-- Coefficientwise bound on the aggregated Ring-LWE noise. -/
theorem rlweResidualNoise_bound (s e r e1 e2 : Fin n → ℤ)
    (Bs Be Br B1 B2 : ℤ) (hBe : 0 ≤ Be) (hBs : 0 ≤ Bs)
    (hs : ∀ i, |s i| ≤ Bs) (he : ∀ i, |e i| ≤ Be) (hr : ∀ i, |r i| ≤ Br)
    (h1 : ∀ i, |e1 i| ≤ B1) (h2 : ∀ i, |e2 i| ≤ B2) (k : Fin n) :
    |rlweResidualNoise s e r e1 e2 k| ≤ n * (Be * Br) + B2 + n * (Bs * B1) := by
  have hA := abs_negaConv_le e r Be Br hBe he hr k
  have hB := abs_negaConv_le s e1 Bs B1 hBs hs h1 k
  have hC := h2 k
  simp only [rlweResidualNoise, Pi.add_apply, Pi.sub_apply]
  have := abs_sub (negaConv e r k + e2 k) (negaConv s e1 k)
  have h4 := abs_add_le (negaConv e r k) (e2 k)
  omega

/-- **Ring-LWE (LPR) decryption, coefficientwise.** -/
def rlweDecrypt (q : ℕ) {n : ℕ} (s : Fin n → ℤ) (c0 : Fin n → ZMod q)
    (c1 : Fin n → ZMod q) (k : Fin n) : Bool :=
  DualRegev.decodeBit q ((c1 - negaConv (toZqVec q s) c0) k)

/-- **Ring-LWE encryption, second component.**  `c₁ = b ⊛ r + e₂ + encode(μ)`,
reduced mod `q`. -/
def rlweCt1 (q : ℕ) {n : ℕ} (b r e2 : Fin n → ℤ) (msg : Fin n → Bool) : Fin n → ZMod q :=
  toZqVec q (rlweCt1Noise b r e2) + fun k => DualRegev.encodeBit q (msg k)

/-- **Ring-LWE correctness.**  With even modulus `q = 2h > 0` and secret,
error and randomness vectors bounded as stated, LPR decryption recovers every
message coefficient, provided the explicit parameter condition
`4·(n·B_e·B_r + B₂ + n·B_s·B₁) < q` holds. -/
theorem rlwe_decrypt_correct (hn : n ≠ 0) (q h : ℕ) (hq : q = 2 * h) (hh : 0 < h)
    (a s e r e1 e2 : Fin n → ℤ) (msg : Fin n → Bool)
    (Bs Be Br B1 B2 : ℤ) (hBe : 0 ≤ Be) (hBs : 0 ≤ Bs)
    (hs : ∀ i, |s i| ≤ Bs) (he : ∀ i, |e i| ≤ Be) (hr : ∀ i, |r i| ≤ Br)
    (h1 : ∀ i, |e1 i| ≤ B1) (h2 : ∀ i, |e2 i| ≤ B2)
    (hparam : 4 * ((n : ℤ) * (Be * Br) + B2 + (n : ℤ) * (Bs * B1)) < (q : ℤ))
    (k : Fin n) :
    rlweDecrypt q s (toZqVec q (rlweCt0 a r e1))
      (rlweCt1 q (rlwePubKey a s e) r e2 msg) k = msg k := by
  have hres := rlwe_residual hn a s e r e1 e2
  have hcoef : (rlweCt1 q (rlwePubKey a s e) r e2 msg
      - negaConv (toZqVec q s) (toZqVec q (rlweCt0 a r e1))) k
      = DualRegev.encodeBit q (msg k)
        + ((rlweResidualNoise s e r e1 e2 k : ℤ) : ZMod q) := by
    have hconv : negaConv (toZqVec q s) (toZqVec q (rlweCt0 a r e1))
        = toZqVec q (negaConv s (rlweCt0 a r e1)) := (toZqVec_negaConv q _ _).symm
    rw [rlweCt1, hconv]
    have : toZqVec q (rlweCt1Noise (rlwePubKey a s e) r e2)
        - toZqVec q (negaConv s (rlweCt0 a r e1))
        = toZqVec q (rlweResidualNoise s e r e1 e2) := by
      rw [← toZqVec_sub, hres]
    simp only [Pi.add_apply, Pi.sub_apply]
    have hthis := congrFun this k
    simp only [Pi.sub_apply, toZqVec] at hthis
    rw [show ((toZqVec q (rlweCt1Noise (rlwePubKey a s e) r e2)) k
        + DualRegev.encodeBit q (msg k)
        - (toZqVec q (negaConv s (rlweCt0 a r e1))) k)
        = ((toZqVec q (rlweCt1Noise (rlwePubKey a s e) r e2)) k
        - (toZqVec q (negaConv s (rlweCt0 a r e1))) k)
        + DualRegev.encodeBit q (msg k) by ring]
    simp only [toZqVec] at hthis ⊢
    rw [hthis]
    ring
  rw [rlweDecrypt, hcoef]
  refine DualRegev.decodeBit_encodeBit_add q h hq hh (msg k) _ ?_
  have hbd := rlweResidualNoise_bound s e r e1 e2 Bs Be Br B1 B2 hBe hBs hs he hr h1 h2 k
  have habs : |rlweResidualNoise s e r e1 e2 k| ≤
      (n : ℤ) * (Be * Br) + B2 + (n : ℤ) * (Bs * B1) := hbd
  omega


/-! ## Section 7: The coefficient model is a faithful *and complete* model

Injectivity (Section 3) says the coefficient vector is determined by the ring
element.  Surjectivity says every element of `ℤ[X]/(Xⁿ+1)` is represented.
Together with the two homomorphism identities this exhibits the coefficient
model `(Fin n → ℤ, +, ⊛, δ₀)` as an isomorphic copy of `ℤ[X]/(Xⁿ+1)`. -/

/-- The multiplicative unit of the coefficient model: the vector `δ₀`. -/
def negaOne (n : ℕ) : Fin n → ℤ := fun i => if (i : ℕ) = 0 then 1 else 0

/-- `δ₀` is a left unit for negacyclic convolution. -/
theorem negaConv_one_left {n : ℕ} (f : Fin n → ℤ) : negaConv (negaOne n) f = f := by
  funext k
  simp only [negaConv, negaOne]
  rw [Finset.sum_eq_single (⟨0, k.pos⟩ : Fin n)]
  · rw [Finset.sum_eq_single k]
    · simp [twist]
    · intro b _ hb
      have hbk : (b : ℕ) ≠ (k : ℕ) := fun hc => hb (Fin.ext hc)
      have h2 : ¬ ((b : ℕ) = n + (k : ℕ)) := by have := b.isLt; omega
      simp only [twist]
      rw [if_neg (by simpa using hbk), if_neg (by simpa using h2)]
      simp
    · intro hc; exact absurd (Finset.mem_univ _) hc
  · intro b _ hb
    have hbv : (b : ℕ) ≠ 0 := fun hc => hb (Fin.ext (by simpa using hc))
    simp [hbv]
  · intro hc; exact absurd (Finset.mem_univ _) hc

/-- `δ₀` embeds to the ring unit. -/
theorem embed_one {R : Type*} [CommRing R] {n : ℕ} (hn : n ≠ 0) (a : R) :
    embed a (negaOne n) = 1 := by
  have hpos : 0 < n := Nat.pos_of_ne_zero hn
  simp only [embed, negaOne]
  rw [Finset.sum_eq_single (⟨0, hpos⟩ : Fin n)]
  · simp
  · intro b _ hb
    have hbv : (b : ℕ) ≠ 0 := fun hc => hb (Fin.ext (by simpa using hc))
    simp [hbv]
  · intro hc; exact absurd (Finset.mem_univ _) hc

/-- **Completeness of the coefficient model.**  Every element of
`ℤ[X]/(Xⁿ+1)` is the image of a coefficient vector. -/
theorem embed_surjective (n : ℕ) (hn : n ≠ 0) :
    Function.Surjective (embed (zeta n) : (Fin n → ℤ) → NegaRing n) := by
  have hd : (AdjoinRoot.powerBasis' (negaPoly_monic n hn)).dim = n := by
    rw [AdjoinRoot.powerBasis'_dim, negaPoly_natDegree]
  set pb := AdjoinRoot.powerBasis' (negaPoly_monic n hn) with hpb
  let b : Module.Basis (Fin n) ℤ (NegaRing n) := pb.basis.reindex (finCongr hd)
  have hb : ∀ i : Fin n, b i = (zeta n) ^ (i : ℕ) := by
    intro i
    simp [b, Module.Basis.reindex_apply, PowerBasis.coe_basis, hpb,
      AdjoinRoot.powerBasis'_gen, zeta]
  intro x
  refine ⟨fun i => b.repr x i, ?_⟩
  have h1 : embed (zeta n) (fun i => b.repr x i) = ∑ i, (b.repr x) i • b i := by
    simp only [embed]
    exact Finset.sum_congr rfl fun i _ => by rw [hb i, zsmul_eq_mul]
  rw [h1, b.sum_repr]

/-- The coefficient embedding is a bijection onto `ℤ[X]/(Xⁿ+1)`. -/
theorem embed_bijective (n : ℕ) (hn : n ≠ 0) :
    Function.Bijective (embed (zeta n) : (Fin n → ℤ) → NegaRing n) :=
  ⟨embed_injective n hn, embed_surjective n hn⟩

/-- **The coefficient model is isomorphic to `ℤ[X]/(Xⁿ+1)`.**  There is a
bijection from integer coefficient vectors to the negacyclic ring that carries
pointwise addition to addition, negacyclic convolution to multiplication, and
`δ₀` to `1`.  This certifies that the convolution rule used throughout Ring-LWE
implementations *is* the ring multiplication, and not merely a bound-compatible
surrogate. -/
theorem negaConv_isomorphism (n : ℕ) (hn : n ≠ 0) :
    ∃ e : (Fin n → ℤ) ≃ NegaRing n,
      (∀ f g, e (f + g) = e f + e g) ∧
      (∀ f g, e (negaConv f g) = e f * e g) ∧
      e (negaOne n) = 1 := by
  refine ⟨Equiv.ofBijective _ (embed_bijective n hn), ?_, ?_, ?_⟩
  · intro f g; exact embed_add (zeta n) f g
  · intro f g; exact embed_negaConv (zeta n) (zeta_pow n) f g
  · exact embed_one hn (zeta n)

end RingLWEStruct

end

/-! ## Axiom verification -/

#print axioms RingLWEStruct.twist_sum
#print axioms RingLWEStruct.embed_negaConv
#print axioms RingLWEStruct.embed_injective
#print axioms RingLWEStruct.negaConv_assoc
#print axioms RingLWEStruct.abs_negaConv_le
#print axioms RingLWEStruct.rlwe_residual
#print axioms RingLWEStruct.rlwe_decrypt_correct
#print axioms RingLWEStruct.embed_surjective
#print axioms RingLWEStruct.negaConv_isomorphism