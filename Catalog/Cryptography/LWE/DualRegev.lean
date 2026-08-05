/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.LWE.OperationalSecurity
import Cryptography.LWE.SearchDecisionCore

/-!
# The Dual-Regev Encryption Scheme: Exact Correctness and IND-CPA

This module constructs the **Dual-Regev** (Gentry–Peikert–Vaikuntanathan)
public-key encryption scheme over `ℤ_q` *concretely* — as honest matrix/vector
algebra, not as an abstract interface — and proves two things about it:

1. **Exact decryption correctness.**  The decryption residual is computed on the
   nose (`dualRegev_residual`): it equals the encoded message plus the single
   integer `x' - ⟨e, x⟩`.  Correctness then follows from a genuinely proved
   rounding theorem for `ZMod q` (`decodeBit_encodeBit_add`) whenever
   `4·|x' - ⟨e, x⟩| < q`, and in particular from the explicit parameter
   condition `4·(B' + m·B_e·B_x) < q` (`dualRegev_correct_of_bounds`).

2. **IND-CPA security**, in the finite-transcript `ℓ¹` model already used by the
   catalog (`Cryptography.LWE.OperationalSecurity`).  The *statistical* half of
   the argument is proved outright: the ideal ciphertext distribution — uniform,
   translated by the message encoding — is literally independent of the message
   (`l1Gap_idealCiphertext_eq_zero`).  Hence the IND-CPA gap collapses to the sum
   of the two decisional-LWE game hops, with **no** additive slack in between
   (`dualRegev_indcpa_gap`, `dualRegev_boolean_advantage`).

## Why this is the sharp statement

The usual textbook write-up of Dual-Regev security says "the ideal game does not
depend on `b`" and moves on.  Here that step is a theorem: translation by any
group element is a measure-preserving bijection of the uniform distribution on a
finite abelian group, so the two ideal ciphertext ensembles are *equal*, giving
`ℓ¹` gap exactly `0`.  Everything else in the bound is exactly the LWE
assumption.

## Main results

* `DualRegev.decodeBit_correct_iff` — the **sharp** rounding dichotomy: decoding
  is correct for both bits exactly when the noise residue lies in the outer
  quarters `[0, q/4) ∪ [3q/4, q)`.
* `DualRegev.decodeBit_encodeBit_add` — the rounding theorem for `ZMod q`
  (`q` even): `decode (encode b + ν) = b` whenever `4|ν| < q`, a corollary of
  the dichotomy.
* `DualRegev.dualRegev_residual` — the exact decryption residual identity.
* `DualRegev.dualRegev_correct` — decryption correctness under `4|ν| < q`.
* `DualRegev.dualRegev_correct_of_bounds` — correctness from short-vector bounds.
* `DualRegev.l1Gap_translate_uniform_eq_zero` — translation invariance of the
  uniform distribution on a finite abelian group.
* `DualRegev.dualRegev_indcpa_gap` — IND-CPA gap `≤ ε₀ + ε₁`.
* `DualRegev.dualRegev_boolean_advantage` — the same bound for every
  deterministic Boolean adversary.
* `DualRegev.noise_tolerance_le_half` — **no** bit-encoding into `ℤ_q` can decode
  correctly on more than `q/2` noise residues.
* `DualRegev.dualRegev_noise_tolerance_optimal` — the midpoint encoding attains
  that bound exactly, so Dual-Regev's encoding is noise-optimal.

## References

* Gentry, Peikert, Vaikuntanathan, "Trapdoors for Hard Lattices and New
  Cryptographic Constructions", STOC 2008.
* Regev, "On Lattices, Learning with Errors, Random Linear Codes, and
  Cryptography", STOC 2005 / JACM 2009.
-/

open Finset BigOperators Matrix

noncomputable section

namespace DualRegev

/-! ## Section 1: Message encoding and rounding decoding over `ZMod q` -/

/-- Encode a bit as `0` or `⌊q/2⌋` in `ℤ_q`. -/
def encodeBit (q : ℕ) (b : Bool) : ZMod q := if b then ((q / 2 : ℕ) : ZMod q) else 0

/-- Decode by rounding: return `true` exactly when the representative lies in the
middle half `[q/4, 3q/4)` of `[0, q)`. -/
def decodeBit (q : ℕ) (c : ZMod q) : Bool := decide (q ≤ 4 * c.val ∧ 4 * c.val < 3 * q)

/-- An integer in `[0, q)` is its own `ZMod q` representative. -/
theorem val_intCast_eq (q : ℕ) [NeZero q] (t : ℤ) (h0 : 0 ≤ t) (h1 : t < q) :
    (((t : ZMod q)).val : ℤ) = t := by
  rw [ZMod.val_intCast, Int.emod_eq_of_lt h0 h1]

/-- **Sharp rounding dichotomy.**  For an even modulus `q = 2h > 0`, rounding
decoding recovers *both* message bits from `encode b + ν` **exactly** when the
residue `r = ν mod q` lies in the outer quarters `[0, q/4) ∪ [3q/4, q)`.

This is an if-and-only-if: it pins down the precise correctness region of the
scheme, and shows in particular that the region is not symmetric in `ν` (the
decoding window `[q/4, 3q/4)` is half-open, so `ν = -q/4` decodes correctly
while `ν = +q/4` does not). -/
theorem decodeBit_correct_iff (q h : ℕ) (hq : q = 2 * h) (hh : 0 < h) (nu : ℤ) :
    ((decodeBit q (encodeBit q false + ((nu : ℤ) : ZMod q)) = false)
      ∧ (decodeBit q (encodeBit q true + ((nu : ℤ) : ZMod q)) = true))
      ↔ (4 * (nu % q) < q ∨ 3 * q ≤ 4 * (nu % q)) := by
  haveI : NeZero q := ⟨by omega⟩
  have hqpos : (0 : ℤ) < q := by exact_mod_cast (by omega : 0 < q)
  set r := nu % (q : ℤ) with hrdef
  have hr0 : 0 ≤ r := Int.emod_nonneg nu (by omega)
  have hrq : r < q := Int.emod_lt_of_pos nu hqpos
  have hcast : ((nu : ℤ) : ZMod q) = ((r : ℤ) : ZMod q) := by
    rw [ZMod.intCast_eq_intCast_iff']
    simp [hrdef, Int.emod_emod_of_dvd]
  have hq2 : q / 2 = h := by omega
  have hval : (((r : ℤ) : ZMod q).val : ℤ) = r := val_intCast_eq q r hr0 hrq
  constructor
  · rintro ⟨h0, -⟩
    by_contra hcon
    push_neg at hcon
    obtain ⟨hc1, hc2⟩ := hcon
    rw [encodeBit, if_neg (by simp), zero_add, hcast, decodeBit] at h0
    simp only [decide_eq_false_iff_not, not_and, not_lt] at h0
    omega
  · intro hcond
    constructor
    · rw [encodeBit, if_neg (by simp), zero_add, hcast, decodeBit]
      simp only [decide_eq_false_iff_not, not_and, not_lt]
      omega
    · rw [encodeBit, if_pos rfl, hq2, hcast, decodeBit]
      simp only [decide_eq_true_eq]
      rcases hcond with hc | hc
      · have he : ((h : ℕ) : ZMod q) + ((r : ℤ) : ZMod q) = (((h : ℤ) + r : ℤ) : ZMod q) := by
          push_cast; ring
        rw [he]
        have hv : ((((h : ℤ) + r : ℤ) : ZMod q).val : ℤ) = (h : ℤ) + r :=
          val_intCast_eq q _ (by omega) (by omega)
        omega
      · have he : ((h : ℕ) : ZMod q) + ((r : ℤ) : ZMod q)
            = (((h : ℤ) + r - q : ℤ) : ZMod q) := by
          push_cast; simp
        rw [he]
        have hv : ((((h : ℤ) + r - q : ℤ) : ZMod q).val : ℤ) = (h : ℤ) + r - q :=
          val_intCast_eq q _ (by omega) (by omega)
        omega

/-- **Rounding theorem.**  For an even modulus `q = 2h > 0`, rounding decoding
recovers the encoded bit from `encode b + ν` for every integer perturbation `ν`
with `4|ν| < q`.  This is the decryption-correctness engine, obtained as the
symmetric special case of the sharp dichotomy above. -/
theorem decodeBit_encodeBit_add (q h : ℕ) (hq : q = 2 * h) (hh : 0 < h)
    (b : Bool) (nu : ℤ) (hnu : 4 * |nu| < (q : ℤ)) :
    decodeBit q (encodeBit q b + ((nu : ℤ) : ZMod q)) = b := by
  have hqpos : (0 : ℤ) < q := by exact_mod_cast (by omega : 0 < q)
  have habs : |4 * nu| < (q : ℤ) := by rw [abs_mul]; simpa using hnu
  rw [abs_lt] at habs
  have hcrit : 4 * (nu % q) < q ∨ 3 * q ≤ 4 * (nu % q) := by
    rcases le_or_gt 0 nu with hs | hs
    · left
      rw [Int.emod_eq_of_lt hs (by omega)]
      omega
    · right
      have hz : nu % (q : ℤ) = nu + q := by
        have h1 : (nu + (q : ℤ) * 1) % q = nu % q := Int.add_mul_emod_self_left nu q 1
        rw [mul_one] at h1
        rw [← h1, Int.emod_eq_of_lt (by omega) (by omega)]
      omega
  obtain ⟨h0, h1⟩ := (decodeBit_correct_iff q h hq hh nu).mpr hcrit
  cases b <;> assumption

/-! Kernel-checked sharpness of the quarter-modulus threshold at `q = 16`: the
hypothesis `4|ν| < q` fails at `ν = ±4`, and decoding indeed breaks at `ν = +4`
while still succeeding at `ν = -4` — the asymmetry predicted by
`decodeBit_correct_iff`. -/

example : decodeBit 16 (encodeBit 16 false + ((4 : ℤ) : ZMod 16)) = true := by decide

example : decodeBit 16 (encodeBit 16 false + (((-4) : ℤ) : ZMod 16)) = false := by decide

example : decodeBit 16 (encodeBit 16 true + (((-4) : ℤ) : ZMod 16)) = true := by decide


/-- The two encodings are distinct for `q > 1` even: the scheme really carries a
bit. -/
theorem encodeBit_injective (q h : ℕ) (hq : q = 2 * h) (hh : 0 < h) :
    encodeBit q false ≠ encodeBit q true := by
  haveI : NeZero q := ⟨by omega⟩
  simp only [encodeBit, Bool.false_eq_true, if_false, if_true, ne_eq, eq_comm]
  intro hcon
  have hlt : q / 2 < q := by omega
  have : ((q / 2 : ℕ) : ZMod q).val = q / 2 := ZMod.val_cast_of_lt hlt
  rw [hcon] at this
  simp [ZMod.val_zero] at this
  omega

/-! ## Section 2: The scheme -/

variable {n m q : ℕ}

/-- Reduce an integer vector modulo `q`. -/
def toZq (q : ℕ) {k : ℕ} (v : Fin k → ℤ) : Fin k → ZMod q := fun i => ((v i : ℤ) : ZMod q)

/-- **Dual-Regev key generation.**  Given the public matrix `A ∈ ℤ_q^{n×m}` and a
short integer secret key `e ∈ ℤ^m`, the public key is the syndrome `u = A·e`. -/
def publicKey (A : Matrix (Fin n) (Fin m) (ZMod q)) (e : Fin m → ℤ) : Fin n → ZMod q :=
  A *ᵥ toZq q e

/-- **Dual-Regev encryption, first component**: `c₀ = Aᵀ·s + x`. -/
def ct0 (A : Matrix (Fin n) (Fin m) (ZMod q)) (s : Fin n → ZMod q) (x : Fin m → ℤ) :
    Fin m → ZMod q :=
  Aᵀ *ᵥ s + toZq q x

/-- **Dual-Regev encryption, second component**: `c₁ = ⟨u, s⟩ + x' + encode b`. -/
def ct1 (u : Fin n → ZMod q) (s : Fin n → ZMod q) (x' : ℤ) (b : Bool) : ZMod q :=
  u ⬝ᵥ s + ((x' : ℤ) : ZMod q) + encodeBit q b

/-- **Dual-Regev decryption**: round `c₁ - ⟨e, c₀⟩`. -/
def decrypt (q : ℕ) {m : ℕ} (e : Fin m → ℤ) (c0 : Fin m → ZMod q) (c1 : ZMod q) : Bool :=
  decodeBit q (c1 - (toZq q e) ⬝ᵥ c0)

/-- A `ZMod q` dot product of two reduced integer vectors is the reduction of the
integer dot product. -/
theorem toZq_dotProduct (q : ℕ) {k : ℕ} (v w : Fin k → ℤ) :
    (toZq q v) ⬝ᵥ (toZq q w) = ((∑ i, v i * w i : ℤ) : ZMod q) := by
  simp only [toZq, dotProduct]
  push_cast
  rfl

/-- **Exact decryption residual.**  For any matrix `A`, secret key `e`,
encryption randomness `s`, and noise `(x, x')`, the quantity that decryption
rounds is *exactly* the encoded message plus the single integer
`x' - ⟨e, x⟩`.  No approximation, no error term is dropped. -/
theorem dualRegev_residual (A : Matrix (Fin n) (Fin m) (ZMod q)) (e : Fin m → ℤ)
    (s : Fin n → ZMod q) (x : Fin m → ℤ) (x' : ℤ) (b : Bool) :
    ct1 (publicKey A e) s x' b - (toZq q e) ⬝ᵥ ct0 A s x
      = encodeBit q b + ((x' - ∑ i, e i * x i : ℤ) : ZMod q) := by
  have hsplit : (toZq q e) ⬝ᵥ ct0 A s x
      = (toZq q e) ⬝ᵥ (Aᵀ *ᵥ s) + (toZq q e) ⬝ᵥ (toZq q x) := by
    rw [ct0, dotProduct_add]
  have hmove : (toZq q e) ⬝ᵥ (Aᵀ *ᵥ s) = (publicKey A e) ⬝ᵥ s := by
    rw [Matrix.dotProduct_mulVec, Matrix.vecMul_transpose, publicKey]
  rw [ct1, hsplit, hmove, toZq_dotProduct]
  push_cast
  ring

/-- **Dual-Regev correctness.**  With an even modulus `q = 2h > 0`, decryption
recovers the message whenever the aggregated noise `x' - ⟨e, x⟩` satisfies the
quarter-modulus bound. -/
theorem dualRegev_correct (q h : ℕ) (hq : q = 2 * h) (hh : 0 < h)
    (A : Matrix (Fin n) (Fin m) (ZMod q)) (e : Fin m → ℤ)
    (s : Fin n → ZMod q) (x : Fin m → ℤ) (x' : ℤ) (b : Bool)
    (hnoise : 4 * |x' - ∑ i, e i * x i| < (q : ℤ)) :
    decrypt q e (ct0 A s x) (ct1 (publicKey A e) s x' b) = b := by
  rw [decrypt, dualRegev_residual A e s x x' b]
  exact decodeBit_encodeBit_add q h hq hh b _ hnoise

/-! ## Section 3: Correctness from explicit short-vector parameters -/

/-- The aggregated Dual-Regev noise is bounded by `B' + m·B_e·B_x`. -/
theorem noise_bound (m : ℕ) (e x : Fin m → ℤ) (x' : ℤ) (Be Bx B' : ℤ)
    (hBe : ∀ i, |e i| ≤ Be) (hBx : ∀ i, |x i| ≤ Bx) (hB' : |x'| ≤ B') :
    |x' - ∑ i, e i * x i| ≤ B' + m * (Be * Bx) := by
  have hterm : ∀ i : Fin m, |e i * x i| ≤ Be * Bx := by
    intro i
    rw [abs_mul]
    exact mul_le_mul (hBe i) (hBx i) (abs_nonneg _)
      (le_trans (abs_nonneg _) (hBe i))
  have hsum : |∑ i, e i * x i| ≤ m * (Be * Bx) := by
    calc |∑ i, e i * x i| ≤ ∑ i, |e i * x i| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i : Fin m, Be * Bx := Finset.sum_le_sum fun i _ => hterm i
      _ = m * (Be * Bx) := by simp [Finset.sum_const]
  calc |x' - ∑ i, e i * x i| ≤ |x'| + |∑ i, e i * x i| := abs_sub _ _
    _ ≤ B' + m * (Be * Bx) := add_le_add hB' hsum

/-- **Parameter-level correctness.**  If the secret key entries are bounded by
`B_e`, the encryption noise entries by `B_x`, the scalar noise by `B'`, and the
modulus satisfies `4·(B' + m·B_e·B_x) < q`, then Dual-Regev decryption is
*always* correct — a fully explicit, checkable parameter condition. -/
theorem dualRegev_correct_of_bounds (q h : ℕ) (hq : q = 2 * h) (hh : 0 < h)
    (A : Matrix (Fin n) (Fin m) (ZMod q)) (e : Fin m → ℤ)
    (s : Fin n → ZMod q) (x : Fin m → ℤ) (x' : ℤ) (b : Bool)
    (Be Bx B' : ℤ)
    (hBe : ∀ i, |e i| ≤ Be) (hBx : ∀ i, |x i| ≤ Bx) (hB' : |x'| ≤ B')
    (hparam : 4 * (B' + m * (Be * Bx)) < (q : ℤ)) :
    decrypt q e (ct0 A s x) (ct1 (publicKey A e) s x' b) = b := by
  refine dualRegev_correct q h hq hh A e s x x' b ?_
  have := noise_bound m e x x' Be Bx B' hBe hBx hB'
  omega

/-! ## Section 4: The statistical heart of IND-CPA

The ideal Dual-Regev ciphertext is uniform, translated by the message encoding.
We prove that this translate does not depend on the message *at all*: the
translated uniform distribution on a finite abelian group is the uniform
distribution.  Hence the middle game hop is free. -/

open LWEOperational

/-- The uniform distribution on a nonempty finite type. -/
def uniformPMF (Ω : Type*) [Fintype Ω] [Nonempty Ω] : FinitePMF Ω where
  mass _ := 1 / (Fintype.card Ω : ℝ)
  nonneg _ := by positivity
  sum_mass := by
    have hpos : (0 : ℝ) < Fintype.card Ω := by
      exact_mod_cast Fintype.card_pos
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp

/-- Translation of a distribution on an additive group by a fixed element. -/
def translatePMF {G : Type*} [Fintype G] [AddGroup G] (g : G) (P : FinitePMF G) :
    FinitePMF G where
  mass y := P.mass (y - g)
  nonneg y := P.nonneg _
  sum_mass := by
    have h := Equiv.sum_comp (Equiv.subRight g) P.mass
    simp only [Equiv.subRight_apply] at h
    rw [h, P.sum_mass]

/-- **Translation invariance of the uniform distribution.**  Translating the
uniform distribution on a finite abelian group by any element leaves it
unchanged.  This is the exact statement "the ideal ciphertext does not depend on
the message". -/
theorem translate_uniformPMF (G : Type*) [Fintype G] [AddGroup G] [Nonempty G] (g : G) :
    (translatePMF g (uniformPMF G)).mass = (uniformPMF G).mass := rfl

/-- Consequently the `ℓ¹` gap between two ideal ciphertext ensembles carrying
*different* messages is exactly `0`: the ideal game leaks nothing. -/
theorem l1Gap_translate_uniform_eq_zero (G : Type*) [Fintype G] [AddGroup G] [Nonempty G]
    (g₀ g₁ : G) :
    l1Gap (translatePMF g₀ (uniformPMF G)) (translatePMF g₁ (uniformPMF G)) = 0 := by
  simp [l1Gap, translatePMF, uniformPMF]

/-! ## Section 5: IND-CPA for Dual-Regev -/

/-- The `ℓ¹` gap is symmetric. -/
theorem l1Gap_symm' {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) :
    l1Gap P Q = l1Gap Q P := by
  simp [l1Gap, abs_sub_comm]

/-- The `ℓ¹` gap satisfies the triangle inequality. -/
theorem l1Gap_triangle' {Ω : Type*} [Fintype Ω] (P Q R : FinitePMF Ω) :
    l1Gap P R ≤ l1Gap P Q + l1Gap Q R := by
  simp only [l1Gap]
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun x _ => abs_sub_le _ _ _

/-- **Dual-Regev IND-CPA.**  Let the challenge ciphertext ensemble for message
bit `b` be `E.challenge b`, and suppose the decisional-LWE game hop replaces it
by the ideal ensemble `translate (msg b) uniform` at cost `ε_b`.  Then the
IND-CPA gap is at most `ε₀ + ε₁`.

The point is that the two ideal ensembles differ by the message translation and
yet are *equal*, so the middle hop is free; the entire bound is the LWE
assumption. -/
theorem dualRegev_indcpa_gap {G : Type*} [Fintype G] [AddGroup G] [Nonempty G]
    (E : EncryptionExperiment G) (msg : Bool → G) (ε₀ ε₁ : ℝ)
    (hzero : l1Gap (E.challenge false) (translatePMF (msg false) (uniformPMF G)) ≤ ε₀)
    (hone : l1Gap (E.challenge true) (translatePMF (msg true) (uniformPMF G)) ≤ ε₁) :
    l1Gap (E.challenge false) (E.challenge true) ≤ ε₀ + ε₁ := by
  have hmid : l1Gap (translatePMF (msg false) (uniformPMF G))
      (translatePMF (msg true) (uniformPMF G)) = 0 :=
    l1Gap_translate_uniform_eq_zero G _ _
  have h1 := l1Gap_triangle' (E.challenge false)
    (translatePMF (msg false) (uniformPMF G)) (E.challenge true)
  have h2 := l1Gap_triangle' (translatePMF (msg false) (uniformPMF G))
    (translatePMF (msg true) (uniformPMF G)) (E.challenge true)
  have h3 := l1Gap_symm' (translatePMF (msg true) (uniformPMF G)) (E.challenge true)
  rw [hmid] at h2
  linarith

/-- **Operational Dual-Regev IND-CPA.**  Every deterministic Boolean adversary
has challenge-bit distinguishing advantage at most `ε₀ + ε₁`, where `ε_b` is the
cost of the decisional-LWE hop on branch `b`.  This upgrades the `ℓ¹` bound to a
statement about actual attackers, via the catalog's operational lemma. -/
theorem dualRegev_boolean_advantage {G : Type*} [Fintype G] [AddGroup G] [Nonempty G]
    (E : EncryptionExperiment G) (msg : Bool → G) (ε₀ ε₁ : ℝ)
    (hzero : l1Gap (E.challenge false) (translatePMF (msg false) (uniformPMF G)) ≤ ε₀)
    (hone : l1Gap (E.challenge true) (translatePMF (msg true) (uniformPMF G)) ≤ ε₁)
    (adversary : G → Bool) :
    |(∑ x with adversary x = true, (E.challenge false).mass x) -
      (∑ x with adversary x = true, (E.challenge true).mass x)| ≤ ε₀ + ε₁ :=
  (boolean_distinguisher_advantage (E.challenge false) (E.challenge true) adversary).trans
    (dualRegev_indcpa_gap E msg ε₀ ε₁ hzero hone)

/-- With a single uniform LWE-hop loss `ε` on each branch, Dual-Regev IND-CPA
advantage is at most `2ε`. -/
theorem dualRegev_indcpa_symmetric {G : Type*} [Fintype G] [AddGroup G] [Nonempty G]
    (E : EncryptionExperiment G) (msg : Bool → G) (ε : ℝ)
    (hclose : ∀ b, l1Gap (E.challenge b) (translatePMF (msg b) (uniformPMF G)) ≤ ε) :
    l1Gap (E.challenge false) (E.challenge true) ≤ 2 * ε := by
  simpa [two_mul] using dualRegev_indcpa_gap E msg ε ε (hclose false) (hclose true)


/-! ## Section 6: Optimality of the midpoint encoding

The correctness condition of Section 1 is not merely convenient — the midpoint
encoding together with middle-half rounding tolerates the largest possible set
of noise residues that *any* bit-encoding into `ℤ_q` can tolerate. -/

/-- The set of noise residues on which Dual-Regev decoding is correct. -/
def GoodNoise (q : ℕ) (r : ZMod q) : Prop := 4 * r.val < q ∨ 3 * q ≤ 4 * r.val

instance (q : ℕ) (r : ZMod q) : Decidable (GoodNoise q r) := by
  unfold GoodNoise; infer_instance

/-- `GoodNoise` is exactly the correctness region of the scheme, restated for a
noise residue in `ℤ_q`. -/
theorem decode_correct_iff_goodNoise (q h : ℕ) [NeZero q] (hq : q = 2 * h) (hh : 0 < h)
    (r : ZMod q) :
    (decodeBit q (encodeBit q false + r) = false ∧ decodeBit q (encodeBit q true + r) = true)
      ↔ GoodNoise q r := by
  have hvr : r.val < q := ZMod.val_lt r
  have hcast : (((r.val : ℕ) : ℤ) : ZMod q) = r := by
    push_cast
    simp [ZMod.natCast_val, ZMod.cast_id]
  have hmod : ((r.val : ℕ) : ℤ) % q = (r.val : ℤ) :=
    Int.emod_eq_of_lt (by positivity) (by exact_mod_cast hvr)
  have hiff := decodeBit_correct_iff q h hq hh ((r.val : ℕ) : ℤ)
  rw [hcast, hmod] at hiff
  rw [hiff]
  unfold GoodNoise
  constructor
  · rintro (hc | hc)
    · left; exact_mod_cast hc
    · right; exact_mod_cast hc
  · rintro (hc | hc)
    · left; exact_mod_cast hc
    · right; exact_mod_cast hc

/-- Shifting the noise by the message gap `q/2` toggles correctness: the good
and bad residues are exchanged. -/
theorem goodNoise_shift (q h : ℕ) [NeZero q] (hq : q = 2 * h) (hh : 0 < h) (r : ZMod q) :
    GoodNoise q (r + ((h : ℕ) : ZMod q)) ↔ ¬ GoodNoise q r := by
  have hvr : r.val < q := ZMod.val_lt r
  have hval : (r + ((h : ℕ) : ZMod q)).val = (r.val + h) % q := by
    rw [ZMod.val_add, ZMod.val_cast_of_lt (by omega)]
  unfold GoodNoise
  rw [hval]
  rcases lt_or_ge (r.val + h) q with hc | hc
  · rw [Nat.mod_eq_of_lt hc]; omega
  · rw [Nat.mod_eq_sub_mod hc, Nat.mod_eq_of_lt (by omega)]; omega

/-- Shifting twice by `q/2` is the identity. -/
theorem shift_involutive (q h : ℕ) [NeZero q] (hq : q = 2 * h) (r : ZMod q) :
    r + ((h : ℕ) : ZMod q) + ((h : ℕ) : ZMod q) = r := by
  have hz : ((h : ℕ) : ZMod q) + ((h : ℕ) : ZMod q) = 0 := by
    have hs : ((h : ℕ) : ZMod q) + ((h : ℕ) : ZMod q) = ((q : ℕ) : ZMod q) := by
      rw [hq]; push_cast; ring
    rw [hs, ZMod.natCast_self]
  rw [add_assoc, hz, add_zero]

/-- **Exactly half of all noise residues are good.** -/
theorem card_goodNoise (q h : ℕ) [NeZero q] (hq : q = 2 * h) (hh : 0 < h) :
    2 * #{r : ZMod q | GoodNoise q r} = q := by
  have hbij : #{r : ZMod q | GoodNoise q r} = #{r : ZMod q | ¬ GoodNoise q r} := by
    refine Finset.card_nbij' (fun r => r + ((h : ℕ) : ZMod q))
      (fun r => r + ((h : ℕ) : ZMod q)) ?_ ?_ ?_ ?_
    · intro r hr
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hr ⊢
      intro hcon
      exact ((goodNoise_shift q h hq hh r).mp hcon) hr
    · intro r hr
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hr ⊢
      exact (goodNoise_shift q h hq hh r).mpr hr
    · intro r _; exact shift_involutive q h hq r
    · intro r _; exact shift_involutive q h hq r
  have htot := Finset.card_filter_add_card_filter_not
    (s := (Finset.univ : Finset (ZMod q))) (GoodNoise q)
  have heta : #(Finset.filter (GoodNoise q) Finset.univ) = #{r : ZMod q | GoodNoise q r} := rfl
  rw [Finset.card_univ, ZMod.card, ← hbij, heta] at htot
  omega

/-- **Universal upper bound on noise tolerance.**  Whatever encoder
`enc : Bool → ℤ_q` and decoder `dec : ℤ_q → Bool` one chooses, the set of noise
residues decoded correctly for *both* message bits has at most `q/2` elements.

The proof is a disjointness argument: translating the correctness region by the
gap `enc(true) − enc(false)` produces a set disjoint from it, and translation
preserves cardinality. -/
theorem noise_tolerance_le_half (q : ℕ) [NeZero q] (enc : Bool → ZMod q) (dec : ZMod q → Bool) :
    2 * #{r : ZMod q | dec (enc false + r) = false ∧ dec (enc true + r) = true} ≤ q := by
  classical
  set S : Finset (ZMod q) :=
    Finset.univ.filter (fun r => dec (enc false + r) = false ∧ dec (enc true + r) = true)
    with hS
  set d : ZMod q := enc true - enc false with hd
  have hdisj : Disjoint S (S.image (fun r => r + d)) := by
    rw [Finset.disjoint_right]
    intro x hx hxS
    simp only [Finset.mem_image] at hx
    obtain ⟨r, hr, hrx⟩ := hx
    simp only [hS, Finset.mem_filter, Finset.mem_univ, true_and] at hr hxS
    have hkey : enc false + x = enc true + r := by
      rw [← hrx, hd]; ring
    rw [hkey] at hxS
    exact absurd hr.2 (by rw [hxS.1]; simp)
  have himg : (S.image (fun r => r + d)).card = S.card :=
    Finset.card_image_of_injective _ (add_left_injective d)
  have hle : S.card + (S.image (fun r => r + d)).card ≤ Fintype.card (ZMod q) := by
    rw [← Finset.card_union_of_disjoint hdisj]
    exact Finset.card_le_univ _
  rw [himg, ZMod.card] at hle
  have heta :
      #{r : ZMod q | dec (enc false + r) = false ∧ dec (enc true + r) = true} = S.card := rfl
  omega

/-- **Dual-Regev's encoding is noise-optimal.**  For an even modulus, the
midpoint encoding with middle-half rounding decodes correctly on exactly `q/2`
noise residues, meeting the universal upper bound of
`noise_tolerance_le_half`. -/
theorem dualRegev_noise_tolerance_optimal (q h : ℕ) [NeZero q] (hq : q = 2 * h) (hh : 0 < h) :
    2 * #{r : ZMod q | decodeBit q (encodeBit q false + r) = false
        ∧ decodeBit q (encodeBit q true + r) = true} = q := by
  have hcard : #{r : ZMod q | decodeBit q (encodeBit q false + r) = false
      ∧ decodeBit q (encodeBit q true + r) = true} = #{r : ZMod q | GoodNoise q r} :=
    congrArg Finset.card
      (Finset.filter_congr fun r _ => decode_correct_iff_goodNoise q h hq hh r)
  rw [hcard]
  exact card_goodNoise q h hq hh

end DualRegev

end

/-! ## Axiom verification -/

#print axioms DualRegev.decodeBit_correct_iff
#print axioms DualRegev.decodeBit_encodeBit_add
#print axioms DualRegev.noise_tolerance_le_half
#print axioms DualRegev.dualRegev_noise_tolerance_optimal
#print axioms DualRegev.dualRegev_residual
#print axioms DualRegev.dualRegev_correct
#print axioms DualRegev.dualRegev_correct_of_bounds
#print axioms DualRegev.l1Gap_translate_uniform_eq_zero
#print axioms DualRegev.dualRegev_indcpa_gap
#print axioms DualRegev.dualRegev_boolean_advantage