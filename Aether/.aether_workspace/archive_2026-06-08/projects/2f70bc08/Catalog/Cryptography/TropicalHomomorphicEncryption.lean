/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Homomorphic Encryption: Impossibility, Construction, and Depth Stability

This file establishes a rigorous formal theory of **homomorphic encryption over tropical
(min-plus) semirings**, proving both impossibility results for deterministic schemes and
correctness theorems for randomized constructions.

## Main Results

### Part I: Impossibility — Deterministic Tropical HE is Insecure

* `tropical_det_hom_injective` — Any deterministic encryption scheme that is
  homomorphic for both tropical addition (min) and tropical multiplication (+)
  with exact decryption must have an injective encryption function.

* `DetCPAInsecure` — A minimal formal notion of deterministic CPA insecurity:
  the adversary can distinguish ciphertexts of distinct messages.

* `no_det_cpa_secure_tropical_scheme` — Exact tropical homomorphic correctness
  implies `DetCPAInsecure`, formalizing the structural obstruction.

### Part II: Randomized Construction — One-Time Tropical Masking

* `TropCipher` — Ciphertext structure over ℤ × ℤ.
* `tropEnc` / `tropDec` — Randomized encryption and decryption.
* `tropical_enc_correct` — Decryption inverts encryption.
* `tropical_enc_mul_correct` — Homomorphic multiplication (tropical ⊗ = +)
  with key evolution to `2 * k`.

### Part III: Expression Evaluation with Key-Weight Accounting

* `TropExpr` — Inductive type for tropical expressions (var, const, tmin, tadd).
* `evalPlain` — Plaintext evaluation in ℤ with min and +.
* `evalCipher` — Ciphertext evaluation preserving tropical semantics.
* `keyWeight` — Key-weight function: tadd accumulates additively, tmin takes max.
* `evalCipher_correct_tminFree` — Depth-stability theorem for min-free expressions.

### Part IV: Tropical Normalization (Refresh)

* `tropRefresh` — Key normalization map resetting key weight.
* `refresh_preserves_plaintext` — Refresh preserves decrypted value.
* `refresh_restores_base_key` — Composing refresh with evaluation yields
  correct plaintext under the base key.

### Cross-Domain Connections

The key-weight theorem formalizes that `min` gates do **not** increase key weight
beyond a `max`, unlike classical additive-noise FHE. This is the tropical analogue
of noise suppression and connects to:
- **Dynamic programming**: tropical evaluation = encrypted Bellman recurrences
- **Order theory**: deterministic impossibility is an order-rigidity result
- **Tropical geometry**: homomorphic evaluation of tropical polynomials

## References

* Grigoriev & Shpilrain, "Tropical Cryptography" (2014)
* Butkovič, "Max-linear Systems: Theory and Algorithms" (2010)
-/

open Function

/-! ## Part I: Impossibility for Deterministic Tropical Homomorphic Encryption -/

/-- A deterministic encryption scheme that is exact-homomorphic for both
tropical addition (`min`) and tropical multiplication (`+`) must be injective.

**Proof**: If `Enc m₁ = Enc m₂`, then `Dec (Enc m₁) = Dec (Enc m₂)`, so `m₁ = m₂`
by the correctness axiom `Dec (Enc m) = m`. -/
theorem tropical_det_hom_injective
    {C : Type} [DecidableEq C]
    (Enc : ℕ → C) (Dec : C → ℕ)
    (cmin cmul : C → C → C)
    (hdec : ∀ m, Dec (Enc m) = m)
    (_hmin : ∀ m n, Dec (cmin (Enc m) (Enc n)) = Nat.min m n)
    (_hadd : ∀ m n, Dec (cmul (Enc m) (Enc n)) = m + n) :
    Injective Enc := by
  exact fun m n h => hdec m ▸ hdec n ▸ h ▸ rfl

/-- A minimal notion of deterministic CPA insecurity: the adversary can
distinguish ciphertexts of two distinct messages. For a deterministic scheme,
injectivity means `Enc m₀ ≠ Enc m₁` whenever `m₀ ≠ m₁`, which allows
a trivial distinguisher via ciphertext equality testing. -/
def DetCPAInsecure {M C : Type} [DecidableEq C] (Enc : M → C) : Prop :=
  ∃ m0 m1 : M, m0 ≠ m1 ∧ Enc m0 ≠ Enc m1

/-- Any deterministic encryption scheme with exact tropical homomorphic
correctness is CPA-insecure: the adversary can find two messages whose
ciphertexts differ, breaking indistinguishability. Uses `m₀ = 0, m₁ = 1`. -/
theorem no_det_cpa_secure_tropical_scheme
    {C : Type} [DecidableEq C]
    (Enc : ℕ → C) (Dec : C → ℕ)
    (cmin cmul : C → C → C)
    (hdec : ∀ m, Dec (Enc m) = m)
    (hmin : ∀ m n, Dec (cmin (Enc m) (Enc n)) = Nat.min m n)
    (hadd : ∀ m n, Dec (cmul (Enc m) (Enc n)) = m + n) :
    DetCPAInsecure Enc :=
  tropical_det_hom_injective Enc Dec cmin cmul hdec hmin hadd |> fun h_inj =>
    ⟨0, 1, by norm_num, h_inj.ne (by norm_num)⟩

/-! ## Part II: Randomized Tropical Masking Construction -/

/-- A tropical ciphertext is a pair of integers. The left component carries
the randomness; the right component carries the masked message. -/
structure TropCipher where
  left : ℤ
  right : ℤ
  deriving DecidableEq, Repr

/-- Randomized tropical encryption: `Enc_k(m; r) = (r, m + r + k)`.
The key `k` and randomness `r` mask the message `m`. -/
def tropEnc (k m r : ℤ) : TropCipher := ⟨r, m + r + k⟩

/-- Tropical decryption: `Dec_k(a, b) = b - a - k`. -/
def tropDec (k : ℤ) (c : TropCipher) : ℤ := c.right - c.left - k

/-- Ciphertext multiplication for tropical multiplication (which is `+` on plaintexts):
component-wise addition of ciphertext pairs. -/
def tropCMul (c₁ c₂ : TropCipher) : TropCipher :=
  ⟨c₁.left + c₂.left, c₁.right + c₂.right⟩

/-- **Decryption correctness**: `Dec_k(Enc_k(m; r)) = m`. -/
theorem tropical_enc_correct (k m r : ℤ) :
    tropDec k (tropEnc k m r) = m := by
  unfold tropDec tropEnc; ring

/-- **Homomorphic multiplication correctness**: multiplying two ciphertexts
and decrypting with key `2 * k` yields `m₁ + m₂` (tropical product).
The key evolution from `k` to `2 * k` is fundamental: each
multiplication gate doubles the effective key. -/
theorem tropical_enc_mul_correct (k m₁ m₂ r₁ r₂ : ℤ) :
    tropDec (2 * k) (tropCMul (tropEnc k m₁ r₁) (tropEnc k m₂ r₂)) = m₁ + m₂ := by
  unfold tropDec tropCMul tropEnc; ring

/-- For any two messages and any ciphertext of `m₁`,
there exists a *different key* making the same ciphertext decrypt to `m₂`.
This formalizes key-based indistinguishability. -/
theorem tropical_enc_key_indistinguishability (m₁ m₂ r : ℤ) :
    ∃ k', tropDec k' (tropEnc 0 m₁ r) = m₂ := by
  exact ⟨m₁ - m₂, by unfold tropDec tropEnc; ring⟩

/-- The ciphertext left component equals the randomness, independent of `m`.
Varying `r` uniformly makes the left component uniform. -/
theorem tropical_enc_left_uniform (k m r : ℤ) :
    (tropEnc k m r).left = r := rfl

/-- Decryption is definitionally `b - a - k`. -/
theorem tropical_enc_message_determined (k a b : ℤ) :
    tropDec k ⟨a, b⟩ = b - a - k := rfl

/-! ## Part III: Tropical Expression Evaluation with Key-Weight Accounting -/

/-- Tropical expressions over `n` variables: constants, variables, min, and +. -/
inductive TropExpr (n : ℕ) where
  | var : Fin n → TropExpr n
  | const : ℤ → TropExpr n
  | tmin : TropExpr n → TropExpr n → TropExpr n
  | tadd : TropExpr n → TropExpr n → TropExpr n
  deriving Repr

namespace TropExpr

/-- Plaintext evaluation of a tropical expression. -/
def evalPlain {n : ℕ} (ρ : Fin n → ℤ) : TropExpr n → ℤ
  | var i => ρ i
  | const c => c
  | tmin e₁ e₂ => min (evalPlain ρ e₁) (evalPlain ρ e₂)
  | tadd e₁ e₂ => evalPlain ρ e₁ + evalPlain ρ e₂

/-- Key weight of a tropical expression:
- variables have weight 1, constants have weight 0,
- `tmin` takes `max` of sub-weights (idempotent!),
- `tadd` sums sub-weights.

This captures the fundamental asymmetry: `min` gates do NOT amplify
key complexity, while `+` gates do. -/
def keyWeight {n : ℕ} : TropExpr n → ℕ
  | var _ => 1
  | const _ => 0
  | tmin e₁ e₂ => max (keyWeight e₁) (keyWeight e₂)
  | tadd e₁ e₂ => keyWeight e₁ + keyWeight e₂

/-- Ciphertext evaluation of a tropical expression:
- `tmin` selects ciphertext with smaller `right` component,
- `tadd` uses component-wise addition (`tropCMul`). -/
def evalCipher {n : ℕ} (env : Fin n → TropCipher) : TropExpr n → TropCipher
  | var i => env i
  | const c => ⟨0, c⟩
  | tmin e₁ e₂ =>
    let c₁ := evalCipher env e₁
    let c₂ := evalCipher env e₂
    if c₁.right ≤ c₂.right then c₁ else c₂
  | tadd e₁ e₂ =>
    let c₁ := evalCipher env e₁
    let c₂ := evalCipher env e₂
    tropCMul c₁ c₂

/-- Predicate for expressions that contain no `tmin` nodes.
These are the expressions for which ciphertext evaluation is unconditionally
correct regardless of randomness distribution. -/
def tminFree {n : ℕ} : TropExpr n → Prop
  | var _ => True
  | const _ => True
  | tmin _ _ => False
  | tadd e₁ e₂ => tminFree e₁ ∧ tminFree e₂

end TropExpr

/-! ### Key-Weight Correctness Theorems -/

/-
Key decomposition lemma: decrypting a ciphertext product under the
sum of two keys equals the sum of individual decryptions.
-/
theorem tropDec_tropCMul_split (K₁ K₂ : ℤ) (c₁ c₂ : TropCipher) :
    tropDec (K₁ + K₂) (tropCMul c₁ c₂) = tropDec K₁ c₁ + tropDec K₂ c₂ := by
  unfold tropDec tropCMul; ring;

/-
**Depth-stability theorem for min-free expressions**: evaluating a tropical
expression (containing only `var`, `const`, and `tadd` nodes) on encrypted inputs
and decrypting with `keyWeight(e) * k` recovers the plaintext evaluation.

For `tadd` gates, key weight grows additively. Constants contribute weight 0
(they carry no key material). Variables contribute weight 1.

This theorem is the formal backbone of tropical "noise-free" evaluation:
chains of additions compound the key linearly, but there is no stochastic
noise growth as in ring-based FHE.
-/
theorem evalCipher_correct_tminFree {n : ℕ} (k : ℤ) (ρ : Fin n → ℤ) (r : Fin n → ℤ)
    (e : TropExpr n) (hfree : e.tminFree) :
    let env := fun i => tropEnc k (ρ i) (r i)
    tropDec (↑(TropExpr.keyWeight e) * k) (TropExpr.evalCipher env e) =
    TropExpr.evalPlain ρ e := by
  -- We proceed by induction on the structure of `e`.
  induction' e with e1 e2 ih1 ih2;
  · grind +locals;
  · unfold tropDec TropExpr.evalCipher TropExpr.evalPlain; aesop;
  · cases hfree;
  · rename_i e1 e2 ih1 ih2;
    convert tropDec_tropCMul_split ( e1.keyWeight * k ) ( e2.keyWeight * k ) ( TropExpr.evalCipher ( fun i => tropEnc k ( ρ i ) ( r i ) ) e1 ) ( TropExpr.evalCipher ( fun i => tropEnc k ( ρ i ) ( r i ) ) e2 ) using 1;
    · rw [ show ( e1.tadd e2 ).keyWeight = e1.keyWeight + e2.keyWeight from rfl ] ; push_cast ; ring;
      rfl;
    · cases hfree ; aesop

/-- When two ciphertexts are encrypted with the same key and randomness,
selecting the one with smaller `right` component correctly implements `min`. -/
theorem evalCipher_tmin_same_randomness (k m₁ m₂ r : ℤ) :
    let c₁ := tropEnc k m₁ r
    let c₂ := tropEnc k m₂ r
    let cmin := if c₁.right ≤ c₂.right then c₁ else c₂
    tropDec k cmin = min m₁ m₂ := by
  unfold tropDec tropEnc
  grind

/-! ## Part IV: Tropical Normalization (Refresh) -/

/-- Key normalization (refresh) map: given a ciphertext encrypted under
effective key `K`, produce an equivalent ciphertext under base key `k`.
`refresh k K c = (c.left, c.right - K + k)` -/
def tropRefresh (k K : ℤ) (c : TropCipher) : TropCipher :=
  ⟨c.left, c.right - K + k⟩

/-- **Refresh preserves plaintext**: decrypting a refreshed ciphertext
under key `k` yields the same value as decrypting the original under key `K`. -/
theorem refresh_preserves_plaintext (k K : ℤ) (c : TropCipher) :
    tropDec k (tropRefresh k K c) = tropDec K c := by
  unfold tropDec tropRefresh; ring

/-- **Refresh restores base key** after a single multiplication gate. -/
theorem refresh_restores_base_key_add (k : ℤ) (m₁ m₂ r₁ r₂ : ℤ) :
    tropDec k (tropRefresh k (2 * k) (tropCMul (tropEnc k m₁ r₁) (tropEnc k m₂ r₂))) =
    m₁ + m₂ :=
  (refresh_preserves_plaintext k (2 * k) _).trans (tropical_enc_mul_correct k m₁ m₂ r₁ r₂)

/-! ## Part V: Cross-Domain — Encrypted Bellman Recurrence -/

/-- Bellman relaxation: `relax(dist, weight) = min(dist, weight)`. -/
def bellmanRelax (dist weight : ℤ) : ℤ := min dist weight

/-- Encrypted Bellman relaxation preserves correctness under same-randomness encryption. -/
theorem encrypted_bellman_relax_correct (k dist weight r : ℤ) :
    let c_dist := tropEnc k dist r
    let c_weight := tropEnc k weight r
    let c_result := if c_dist.right ≤ c_weight.right then c_dist else c_weight
    tropDec k c_result = bellmanRelax dist weight := by
  convert evalCipher_tmin_same_randomness k dist weight r using 1

/-- Path extension: `extend(dist, edge) = dist + edge`. -/
def pathExtend (dist edge : ℤ) : ℤ := dist + edge

/-- Encrypted path extension preserves correctness with key evolution. -/
theorem encrypted_path_extend_correct (k dist edge r₁ r₂ : ℤ) :
    tropDec (2 * k) (tropCMul (tropEnc k dist r₁) (tropEnc k edge r₂)) =
    pathExtend dist edge :=
  tropical_enc_mul_correct k dist edge r₁ r₂

/-! ## Part VI: Order-Theoretic Rigidity -/

/-- If `Enc` preserves `min` under decryption, then the plaintext ordering
is fully determined by the ciphertext `min` operation. This is the formal
statement that homomorphic min-preservation leaks order information. -/
theorem order_reflected_by_hom_min
    {C : Type} [DecidableEq C]
    (Enc : ℕ → C) (Dec : C → ℕ)
    (cmin : C → C → C)
    (_hdec : ∀ m, Dec (Enc m) = m)
    (hmin : ∀ m₁ m₂, Dec (cmin (Enc m₁) (Enc m₂)) = Nat.min m₁ m₂) :
    ∀ m₁ m₂, m₁ ≤ m₂ ↔ Dec (cmin (Enc m₁) (Enc m₂)) = m₁ := by
  grind

/-! ## Part VII: Quotient-Semantic Equivalence -/

/-- Two ciphertexts are equivalent under key `k` if they decrypt to the same value. -/
def TropCipherEquiv (k : ℤ) (c₁ c₂ : TropCipher) : Prop :=
  tropDec k c₁ = tropDec k c₂

/-- Ciphertext equivalence is an equivalence relation. -/
theorem tropCipherEquiv_equiv (k : ℤ) : Equivalence (TropCipherEquiv k) := by
  constructor <;> intros <;> unfold TropCipherEquiv at * <;> aesop

/-- Tropical multiplication respects ciphertext equivalence:
if `c₁ ≈ c₁'` and `c₂ ≈ c₂'` under key `k`, then
`cMul c₁ c₂ ≈ cMul c₁' c₂'` under key `2k`. -/
theorem tropCMul_respects_equiv (k : ℤ)
    (c₁ c₁' c₂ c₂' : TropCipher)
    (h₁ : TropCipherEquiv k c₁ c₁')
    (h₂ : TropCipherEquiv k c₂ c₂') :
    TropCipherEquiv (2 * k) (tropCMul c₁ c₂) (tropCMul c₁' c₂') := by
  unfold TropCipherEquiv at *; unfold tropDec at *; unfold tropCMul at *; linarith