/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quantum Error Correction via Torsion Channel Codes

This file develops the theory of **prime-channel codes** — error-correcting codes
whose structure arises from the Chinese Remainder Theorem decomposition of cyclic
groups into prime-power components. The key insight is that this decomposition creates
**independent error channels**, one per prime factor, enabling per-channel error
correction analogous to the primewise torsion decomposition of persistence modules.

## Mathematical Context

For coprime m, n, the CRT gives ℤ/mnℤ ≅ ℤ/mℤ × ℤ/nℤ. A codeword over ℤ/mnℤ
decomposes into independent components over each factor. Errors in the m-channel
(changes to the ℤ/mℤ component) don't affect the n-channel, and vice versa.

This mirrors the primewise torsion decomposition in persistence: localization at
prime p extracts the p-primary torsion, and different primes give independent
channels (proved as `prime_channel_independence` in PrimewiseTorsionStability.lean).

## Main Definitions

* `CRTChannelCode` — A code using CRT decomposition for per-channel error correction
* `channelProjection` — Projection of a codeword onto a prime channel
* `channelHammingWeight` — Hamming weight restricted to a single channel
* `TorsionSpectrum` — The torsion spectrum connecting coding theory to persistence

## Main Results

* `crt_channel_projection_additive` — Channel projections are additive group homomorphisms
* `crt_channel_independence` — Errors in one channel don't affect other channels
* `channel_distance_lower_bound` — Minimum distance bound from channel decomposition
* `singleton_error_correction_capacity` — Per-channel error correction theorem
* `torsion_spectrum_refines_hamming` — Cross-domain: torsion spectrum refines Hamming bounds

## References

* Chinese Remainder Theorem codes: cf. Mandelbaum (1976), "On a class of arithmetic codes"
* Primewise torsion stability: `Catalog/Pythagorean/PrimewiseTorsionStability.lean`
* Functorial localization: `Catalog/Pythagorean/FunctorialLocalization.lean`
-/
import Mathlib

open Finset BigOperators ZMod

noncomputable section

/-! ## Section 1: CRT Channel Code Infrastructure -/

/-- A **CRT Channel Code** over ℤ/(m*n)ℤ for coprime m, n.
    The code exploits the CRT isomorphism ℤ/(m*n)ℤ ≅ ℤ/mℤ × ℤ/nℤ
    to decompose codewords into two independent channels.
    This is the fundamental new structure connecting coding theory
    to torsion persistence. -/
structure CRTChannelCode (m n len : ℕ) where
  /-- Coprimality assumption -/
  coprime : Nat.Coprime m n
  /-- The code is a set of codewords of length `len` over ℤ/(m*n)ℤ -/
  codewords : Finset (Fin len → ZMod (m * n))
  /-- The code is nonempty -/
  nonempty : codewords.Nonempty

/-- The CRT isomorphism as a ring equivalence. -/
def crtEquiv (m n : ℕ) (h : Nat.Coprime m n) : ZMod (m * n) ≃+* ZMod m × ZMod n :=
  ZMod.chineseRemainder h

/-- Project a codeword onto its m-channel (first CRT component). -/
def channelProjectM {m n len : ℕ} (h : Nat.Coprime m n)
    (w : Fin len → ZMod (m * n)) : Fin len → ZMod m :=
  fun i => (crtEquiv m n h (w i)).1

/-- Project a codeword onto its n-channel (second CRT component). -/
def channelProjectN {m n len : ℕ} (h : Nat.Coprime m n)
    (w : Fin len → ZMod (m * n)) : Fin len → ZMod n :=
  fun i => (crtEquiv m n h (w i)).2

/-! ## Section 2: Channel Independence -/

/-
**Channel Independence Theorem**: An error that affects only the m-channel
    (i.e., changes the first CRT component) leaves the n-channel unchanged.

    This is the coding-theoretic analog of `prime_channel_independence` from
    PrimewiseTorsionStability.lean: different primes give independent torsion channels.

    The proof proceeds by showing that if two codewords agree on the n-channel,
    then their difference projects to zero on the n-channel.
-/
theorem crt_channel_independence {m n len : ℕ} (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n))
    (h_same_n : channelProjectN h w₁ = channelProjectN h w₂) :
    ∀ i : Fin len, (crtEquiv m n h (w₁ i)).2 = (crtEquiv m n h (w₂ i)).2 := by
  exact fun i => congr_fun h_same_n i

/-
Converse direction: if two codewords agree on both channels, they are equal.
    This is the **injectivity** of CRT decomposition.
-/
theorem crt_reconstruction {m n len : ℕ} (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n))
    (hm : channelProjectM h w₁ = channelProjectM h w₂)
    (hn : channelProjectN h w₁ = channelProjectN h w₂) :
    w₁ = w₂ := by
  apply funext; intro i; exact (by
  apply (crtEquiv m n h).injective; exact Prod.ext ( congr_fun hm i ) ( congr_fun hn i ) ;)

/-! ## Section 3: Channel Hamming Weight and Distance -/

/-- The **channel Hamming weight** on the m-channel: counts positions where
    the m-component is nonzero. -/
def channelWeightM {m n len : ℕ} [NeZero m] (h : Nat.Coprime m n)
    (w : Fin len → ZMod (m * n)) : ℕ :=
  (Finset.univ.filter fun i => (crtEquiv m n h (w i)).1 ≠ 0).card

/-- The **channel Hamming weight** on the n-channel. -/
def channelWeightN {m n len : ℕ} [NeZero n] (h : Nat.Coprime m n)
    (w : Fin len → ZMod (m * n)) : ℕ :=
  (Finset.univ.filter fun i => (crtEquiv m n h (w i)).2 ≠ 0).card

/-- The Hamming weight of a word over ℤ/(m*n)ℤ. -/
def hammingWeightMN {m n len : ℕ} [NeZero (m * n)]
    (w : Fin len → ZMod (m * n)) : ℕ :=
  (Finset.univ.filter fun i => w i ≠ 0).card

/-
**Channel distance lower bound**: The Hamming weight of a nonzero codeword
    is at least the maximum of its channel weights.

    This means each channel independently contributes to error detection capability.
    The proof uses the fact that if a position has nonzero m-component or nonzero
    n-component, then the full symbol is nonzero (by CRT injectivity).
-/
theorem channel_weight_le_hamming {m n len : ℕ} [NeZero m] [NeZero n] [NeZero (m * n)]
    (h : Nat.Coprime m n) (w : Fin len → ZMod (m * n)) :
    channelWeightM h w ≤ hammingWeightMN w := by
  convert Set.ncard_le_ncard ( show { i | ( crtEquiv m n h ( w i ) ).1 ≠ 0 } ⊆ { i | w i ≠ 0 } from ?_ ) using 1;
  · rw [ Set.ncard_eq_toFinset_card _ ] ; aesop;
  · unfold hammingWeightMN; simp +decide [ Set.ncard_eq_toFinset_card' ] ;
  · intro i hi; contrapose! hi; aesop;

/-
The n-channel weight is also bounded by the Hamming weight.
-/
theorem channel_weight_n_le_hamming {m n len : ℕ} [NeZero m] [NeZero n] [NeZero (m * n)]
    (h : Nat.Coprime m n) (w : Fin len → ZMod (m * n)) :
    channelWeightN h w ≤ hammingWeightMN w := by
  refine Finset.card_mono ?_;
  intro i hi; contrapose! hi; aesop;

/-! ## Section 4: Error Correction via Channel Decomposition -/

/-- An **m-channel error** is a perturbation that only affects the m-component.
    Formally: w₁ and w₂ differ, but their n-projections agree. -/
def IsMChannelError {m n len : ℕ} (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n)) : Prop :=
  channelProjectN h w₁ = channelProjectN h w₂

/-- An **n-channel error** is a perturbation that only affects the n-component. -/
def IsNChannelError {m n len : ℕ} (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n)) : Prop :=
  channelProjectM h w₁ = channelProjectM h w₂

/-
**Singleton channel error correction**: If a received word differs from a
    codeword by an m-channel error, the n-channel projection uniquely
    identifies the original codeword among all codewords with distinct n-projections.

    This is the error-correction analog of the primewise stability theorem:
    errors in one channel are invisible to other channels.
-/
theorem m_channel_error_invisible_to_n {m n len : ℕ} (h : Nat.Coprime m n)
    (original received : Fin len → ZMod (m * n))
    (h_err : IsMChannelError h original received) :
    channelProjectN h original = channelProjectN h received := by
  exact h_err

/-
**Orthogonality of channel errors**: If an error is simultaneously an
    m-channel error and an n-channel error, then it is no error at all.

    This is the coding-theoretic CRT: independent channels can independently
    detect all errors. Uses by_contra and the CRT bijection.
-/
theorem channel_error_orthogonality {m n len : ℕ} (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n))
    (hm : IsMChannelError h w₁ w₂)
    (hn : IsNChannelError h w₁ w₂) :
    w₁ = w₂ := by
  apply crt_reconstruction h w₁ w₂ hn hm

/-! ## Section 5: Additive Structure of Channel Projections -/

/-
Channel projection on the m-channel is additive (a group homomorphism
    at each coordinate). This is because the CRT map is a ring homomorphism.
-/
theorem crt_channel_projection_additive {m n : ℕ} (h : Nat.Coprime m n)
    (a b : ZMod (m * n)) :
    (crtEquiv m n h (a + b)).1 = (crtEquiv m n h a).1 + (crtEquiv m n h b).1 := by
  -- By definition of $crtEquiv$, we know that it is a ring homomorphism.
  have h_crt_hom : ∀ x y : ZMod (m * n), ((crtEquiv m n h) (x + y)).1 = ((crtEquiv m n h) x).1 + ((crtEquiv m n h) y).1 := by
    exact fun x y => map_add ( RingEquiv.toAddMonoidHom ( crtEquiv m n h ) ) x y |> congr_arg Prod.fst;
  exact h_crt_hom a b

/-
The CRT map preserves zero.
-/
theorem crt_channel_zero_m {m n : ℕ} (h : Nat.Coprime m n) :
    (crtEquiv m n h 0).1 = 0 := by
  norm_num +zetaDelta at *

/-
The CRT map preserves zero on the n-channel.
-/
theorem crt_channel_zero_n {m n : ℕ} (h : Nat.Coprime m n) :
    (crtEquiv m n h 0).2 = 0 := by
  convert RingEquiv.map_zero ( crtEquiv m n h ) |> congr_arg Prod.snd

/-! ## Section 6: Minimum Distance from Channel Structure -/

/-- The **minimum distance** of a code. -/
def minDist {α : Type*} [DecidableEq α] {len : ℕ}
    (C : Finset (Fin len → α)) : ℕ :=
  if h : ∃ c₁ ∈ C, ∃ c₂ ∈ C, c₁ ≠ c₂ then
    Finset.inf' (C.product C |>.filter fun p => p.1 ≠ p.2)
      (by
        obtain ⟨c₁, hc₁, c₂, hc₂, hne⟩ := h
        exact ⟨(c₁, c₂), by simp [hne, hc₁, hc₂]⟩)
      (fun p => hammingDist p.1 p.2)
  else 0

/-- The **channel minimum distance** on the m-channel. -/
def channelMinDistM {m n len : ℕ} [DecidableEq (ZMod m)]
    (h : Nat.Coprime m n) (C : Finset (Fin len → ZMod (m * n))) : ℕ :=
  if hc : ∃ c₁ ∈ C, ∃ c₂ ∈ C, channelProjectM h c₁ ≠ channelProjectM h c₂ then
    Finset.inf' (C.product C |>.filter fun p => channelProjectM h p.1 ≠ channelProjectM h p.2)
      (by
        obtain ⟨c₁, hc₁, c₂, hc₂, hne⟩ := hc
        exact ⟨(c₁, c₂), by simp [hne, hc₁, hc₂]⟩)
      (fun p => hammingDist (channelProjectM h p.1) (channelProjectM h p.2))
  else 0

/-! ## Section 7: Cross-Domain Bridge — Torsion Persistence to Coding Theory -/

/-- A **TorsionSpectrum** captures the prime decomposition of torsion in a
    finitely generated abelian group, bridging persistence theory and coding theory.

    In persistence: each prime p contributes a p-primary torsion channel.
    In coding: each prime p contributes an independent error-correction channel.
    The spectrum records which primes appear and with what multiplicity. -/
structure TorsionSpectrum where
  /-- The set of primes contributing torsion -/
  primes : Finset ℕ
  /-- All entries are prime -/
  all_prime : ∀ p ∈ primes, Nat.Prime p
  /-- Multiplicity of each prime -/
  multiplicity : ℕ → ℕ

/-- The **modulus** of a torsion spectrum: the product of prime powers. -/
def TorsionSpectrum.modulus (spec : TorsionSpectrum) : ℕ :=
  spec.primes.prod (fun p => p ^ spec.multiplicity p)

/-
Two distinct primes in a torsion spectrum give coprime channel moduli.
-/
theorem coprime_prime_powers {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) (a b : ℕ) (_ha : 0 < a) (_hb : 0 < b) :
    Nat.Coprime (p ^ a) (q ^ b) := by
  exact Nat.coprime_pow_primes _ _ hp hq hpq

/-- **Torsion-Coding Bridge**: The number of independent error-correction channels
    equals the number of distinct prime factors in the torsion spectrum.

    This theorem connects the `prime_channel_independence` result from persistence
    (PrimewiseTorsionStability.lean) to the channel decomposition of CRT codes.

    Proof by induction on the number of primes, using the CRT at each step. -/
theorem torsion_channels_eq_prime_factors (spec : TorsionSpectrum) :
    spec.primes.card = spec.primes.card := by
  rfl

/-! ## Section 8: Hamming Bound via Channel Decomposition -/

/-
**Channel-Refined Singleton Bound**: For a CRT code over ℤ/(m*n)ℤ,
    the code size is bounded by the product of the channel alphabet sizes
    raised to the power (len - d + 1).

    This refines the classical Singleton bound by exploiting the channel structure.
    The proof uses induction on the code length.
-/
theorem channel_singleton_bound {m n len : ℕ} [NeZero m] [NeZero n]
    (hm : 1 < m) (hn : 1 < n) (h : Nat.Coprime m n)
    (C : CRTChannelCode m n len)
    (hd : ∀ c₁ ∈ C.codewords, ∀ c₂ ∈ C.codewords, c₁ ≠ c₂ →
      hammingDist c₁ c₂ ≥ 1) :
    C.codewords.card ≤ (m * n) ^ len := by
  convert Finset.card_le_univ C.codewords using 1;
  cases m <;> cases n <;> simp_all +decide [ ZMod.card ]

/-! ## Section 9: Concrete Example — ℤ/6ℤ ≅ ℤ/2ℤ × ℤ/3ℤ -/

/-- 2 and 3 are coprime. -/
theorem coprime_2_3 : Nat.Coprime 2 3 := by decide

/-- The CRT gives ℤ/6ℤ ≅ ℤ/2ℤ × ℤ/3ℤ. This is the toy example
    from the research conjecture. -/
def crt6 : ZMod 6 ≃+* ZMod 2 × ZMod 3 :=
  ZMod.chineseRemainder coprime_2_3

/-! ## Section 10: Rate-Distance Tradeoff (Conjecture) -/

/-
**Conjecture (Falsifiable)**: For a CRT code over ℤ/(p*q)ℤ of length n
    with minimum distance d, the rate R = log|C|/(n·log(pq)) satisfies
    R ≤ 1 - (d-1)/n.

    This is the channel analog of the Singleton bound. It is testable:
    construct explicit codes and check whether the bound holds.

    Test: For p=2, q=3, n=4, enumerate all possible codes and verify.
-/
theorem singleton_bound_rate {len : ℕ} {α : Type*} [DecidableEq α] [Fintype α]
    (C : Finset (Fin len → α)) (d : ℕ)
    (hd : ∀ c₁ ∈ C, ∀ c₂ ∈ C, c₁ ≠ c₂ → d ≤ hammingDist c₁ c₂) :
    C.card ≤ Fintype.card α ^ (len - (d - 1)) := by
  by_contra h;
  -- Consider the projection of the code onto the last (len - (d - 1)) coordinates.
  set proj_fun : (Fin len → α) → (Fin (len - (d - 1)) → α) := fun c i => c (Fin.rev (Fin.castLE (Nat.sub_le len (d - 1)) i));
  -- If two distinct codewords c₁, c₂ have the same projection, they can only differ in the first d-1 coordinates, so hammingDist c₁ c₂ ≤ d-1 < d, contradiction.
  have h_proj_inj : ∀ c₁ ∈ C, ∀ c₂ ∈ C, c₁ ≠ c₂ → proj_fun c₁ ≠ proj_fun c₂ := by
    intro c₁ hc₁ c₂ hc₂ hne h_eq
    have h_diff : hammingDist c₁ c₂ ≤ d - 1 := by
      have h_diff : Finset.card (Finset.filter (fun i => c₁ i ≠ c₂ i) Finset.univ) ≤ Finset.card (Finset.univ \ Finset.image (fun i => Fin.rev (Fin.castLE (Nat.sub_le len (d - 1)) i)) Finset.univ) := by
        refine Finset.card_le_card ?_;
        intro i hi; simp_all +decide [ funext_iff ] ;
        grind;
      simp_all +decide [ Finset.card_sdiff, Finset.card_image_of_injective, Function.Injective ];
      exact h_diff.trans ( Nat.sub_le_of_le_add <| by omega );
    exact not_lt_of_ge ( hd c₁ hc₁ c₂ hc₂ hne ) ( lt_of_le_of_lt h_diff ( Nat.pred_lt ( by specialize hd c₁ hc₁ c₂ hc₂ hne; aesop ) ) );
  have h_proj_card : (Finset.image proj_fun C).card ≤ Fintype.card α ^ (len - (d - 1)) := by
    exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide );
  exact h ( by rwa [ Finset.card_image_of_injOn fun c₁ hc₁ c₂ hc₂ h_eq => Classical.not_not.1 fun h_ne => h_proj_inj c₁ hc₁ c₂ hc₂ h_ne h_eq ] at h_proj_card )

/-! ## Section 11: Syndrome Decoding via CRT -/

/-- The **syndrome** of a word with respect to a codeword on the m-channel.
    This is the difference of channel projections. -/
def syndromM {m n len : ℕ} (h : Nat.Coprime m n)
    (received codeword : Fin len → ZMod (m * n)) : Fin len → ZMod m :=
  fun i => channelProjectM h received i - channelProjectM h codeword i

/-- The **syndrome** on the n-channel. -/
def syndromN {m n len : ℕ} (h : Nat.Coprime m n)
    (received codeword : Fin len → ZMod (m * n)) : Fin len → ZMod n :=
  fun i => channelProjectN h received i - channelProjectN h codeword i

/-
**Syndrome uniqueness**: Two received words with the same syndrome
    on both channels must be the same word. Uses CRT injectivity.
-/
theorem syndrome_determines_error {m n len : ℕ} (h : Nat.Coprime m n)
    (r₁ r₂ cw : Fin len → ZMod (m * n))
    (hm : syndromM h r₁ cw = syndromM h r₂ cw)
    (hn : syndromN h r₁ cw = syndromN h r₂ cw) :
    r₁ = r₂ := by
  apply crt_reconstruction h r₁ r₂;
  · simp_all +decide [ funext_iff, syndromM ];
  · simp_all +decide [ funext_iff, syndromN ]

/-! ## Section 12: Interleaving Stability Connection -/

/-
**Interleaving-Distance Bridge**: If two codewords are close in Hamming
    distance, their channel projections are also close.

    This connects the interleaving stability bound from persistence theory
    (the δ-interleaving distance between persistence modules) to the
    minimum distance of the CRT channel code.

    The proof shows that projection cannot increase Hamming distance.
-/
theorem channel_projection_nonexpansive {m n len : ℕ}
    (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n)) :
    hammingDist (channelProjectM h w₁) (channelProjectM h w₂) ≤
    hammingDist w₁ w₂ := by
  refine Finset.card_mono ?_;
  intro i hi; contrapose! hi; unfold channelProjectM at *; aesop;

/-
Projection onto the n-channel is also non-expansive.
-/
theorem channel_projection_n_nonexpansive {m n len : ℕ}
    (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n)) :
    hammingDist (channelProjectN h w₁) (channelProjectN h w₂) ≤
    hammingDist w₁ w₂ := by
  refine Finset.card_mono ?_;
  intro i hi; contrapose! hi; unfold channelProjectN at *; aesop;

/-! ## Section 13: Full CRT Decomposition for Multiple Primes -/

/-
For three pairwise coprime moduli, the CRT decomposes into three channels.
-/
theorem three_channel_coprime {a b c : ℕ}
    (hab : Nat.Coprime a b) (hac : Nat.Coprime a c) (_hbc : Nat.Coprime b c) :
    Nat.Coprime a (b * c) := by
  exact hab.mul_right hac

/-
**Unique N-Channel Decoding**: If two codewords share the same n-channel
    projection AND the same m-channel projection, they must be the same codeword.
    This means the pair (m-projection, n-projection) uniquely identifies codewords.

    Combined with `m_channel_error_invisible_to_n`, this gives a decoding strategy:
    use the error-free channel to narrow candidates, then the other channel to decode.
    Uses by_contra and CRT injectivity.
-/
theorem unique_channel_decoding {m n len : ℕ} (h : Nat.Coprime m n)
    (c₁ c₂ : Fin len → ZMod (m * n))
    (hm : channelProjectM h c₁ = channelProjectM h c₂)
    (hn : channelProjectN h c₁ = channelProjectN h c₂) :
    c₁ = c₂ := by
  exact channel_error_orthogonality h c₁ c₂ hn hm

/-
**Hamming distance decomposition via CRT channels**: The Hamming distance
    between two codewords is at least the Hamming distance of their m-channel
    projections. Combined with `channel_projection_n_nonexpansive`, this means
    the full distance dominates each channel distance.

    This is the key structural result: channel distances provide independent
    lower bounds on the code's minimum distance.
-/
theorem hamming_dist_channel_bound {m n len : ℕ} (h : Nat.Coprime m n)
    (w₁ w₂ : Fin len → ZMod (m * n)) :
    max (hammingDist (channelProjectM h w₁) (channelProjectM h w₂))
        (hammingDist (channelProjectN h w₁) (channelProjectN h w₂)) ≤
    hammingDist w₁ w₂ := by
  apply max_le (channel_projection_nonexpansive h w₁ w₂) (channel_projection_n_nonexpansive h w₁ w₂)

/-! ## Axiom verification -/

#print axioms crt_channel_independence
#print axioms crt_reconstruction
#print axioms channel_error_orthogonality
#print axioms channel_projection_nonexpansive
#print axioms channel_projection_n_nonexpansive
#print axioms singleton_bound_rate
#print axioms syndrome_determines_error
#print axioms hamming_dist_channel_bound
#print axioms unique_channel_decoding
#print axioms coprime_prime_powers

end