import Cryptography.WeilPairingClassification

/-!
# Adversarial review of the catalog BLS model, and a satisfiable replacement

## Part 1: the catalog model is degenerate

The catalog structure `Cryptography.WeilBLS.BLSParams` requires
`Function.Injective (fun P => pairing.pair P generator)`.  Because a Weil pairing is
*alternating*, `e(G,G) = 1 = e(0,G)`, so injectivity immediately forces `G = 0` and then
`e(Q,0) = 1 = e(0,0)` forces every torsion point to vanish
(`BLSParams.torsion_trivial`).  Hence `BLSParams` can only be instantiated on curves with
**trivial** `n`-torsion, and every statement proved about it — including the catalog's own
`verifies_iff_eq_sign` and `forgery_solves_cdh` — is vacuous for a real curve.  We prove
this obstruction rather than paper over it.

## Part 2: the corrected setting

`BLSSetting` replaces the impossible axiom by the true requirement of pairing-based BLS:
two generators `gen₁` (signature group) and `gen₂` (key group) whose pairing value
`ζ = e(gen₁, gen₂)` has exact order `n`.  Signatures live in the cyclic group `⟨gen₁⟩`,
where the verification map *is* injective (`verifies_iff_modEq`).  All of the BLS theory
— correctness, uniqueness of signatures, the EUF-CMA-to-CDH reduction with fresh-message
programming, aggregation, aggregate-forgery extraction, batch verification and the
rogue-key attack — is re-proved in this model.

## Part 3: non-vacuity

`detBLSSetting` and `curveBLSSetting` construct instances: unconditionally in the
determinant model `(ZMod n)²`, and on any Weierstrass curve whose `n`-torsion is
isomorphic to `(ZMod n)²`.  So, unlike `BLSParams`, the corrected model is inhabited.
-/

open scoped BigOperators
open Finset

namespace Cryptography.WeilBLS

universe u v w

/-! ## Part 1: the catalog model forces trivial torsion -/

section Vacuity

variable {F : Type u} [Field F] [DecidableEq F] {W : WeierstrassCurve F} {n : ℕ}
  {μ : Type v} [CommGroup μ]

/-- Alternation forces the distinguished generator of a `BLSParams` to be zero. -/
theorem BLSParams.generator_eq_zero (P : BLSParams W n μ) : P.generator = 0 := by
  apply P.pairing_generator_injective
  show P.pairing.pair P.generator P.generator = P.pairing.pair 0 P.generator
  rw [P.pairing.pair_self, P.pairing.pair_zero_left]

/-- **Obstruction theorem.**  The catalog's injectivity axiom is satisfiable only when
the whole `n`-torsion group is trivial. -/
theorem BLSParams.torsion_trivial (P : BLSParams W n μ) (Q : torsionPoints W n) : Q = 0 := by
  apply P.pairing_generator_injective
  show P.pairing.pair Q P.generator = P.pairing.pair 0 P.generator
  rw [P.generator_eq_zero, P.pairing.pair_zero_right, P.pairing.pair_zero_left]

/-- Consequently no curve with a nonzero `n`-torsion point admits `BLSParams`. -/
theorem BLSParams.not_exists_of_nontrivial_torsion (Q : torsionPoints W n) (hQ : Q ≠ 0) :
    IsEmpty (BLSParams W n μ) :=
  ⟨fun P => hQ (P.torsion_trivial Q)⟩

end Vacuity

/-! ## Part 2: the corrected asymmetric setting -/

/-- Congruent exponents act equally on an `n`-torsion element. -/
theorem nsmul_eq_of_modEq {A : Type u} [AddCommGroup A] {x : A} {m : ℕ} (hx : m • x = 0)
    {a b : ℕ} (h : a ≡ b [MOD m]) : a • x = b • x := by
  have key : ∀ c : ℕ, c • x = (c % m) • x := by
    intro c
    conv_lhs => rw [← Nat.div_add_mod c m]
    rw [add_nsmul, mul_nsmul, hx, smul_zero, zero_add]
  rw [key a, key b, h]

/-- A **pairing-based BLS setting**: an alternating pairing together with a signature
generator `gen₁`, a key generator `gen₂`, and the requirement that the pairing value
`ζ = e(gen₁, gen₂)` has exact order `n`.  This is the standard type-3 (asymmetric)
pairing configuration, and unlike `BLSParams` it is satisfiable. -/
structure BLSSetting (A : Type u) [AddCommGroup A] (μ : Type v) [CommGroup μ] (n : ℕ) where
  /-- the underlying alternating (Weil) pairing -/
  pairing : AltPairing A μ
  /-- generator of the signature group -/
  gen₁ : A
  /-- generator of the key group -/
  gen₂ : A
  /-- the signature group is `n`-torsion -/
  torsion₁ : n • gen₁ = 0
  /-- nondegeneracy in the only form that matters: the pairing value has exact order `n` -/
  root_order : orderOf (pairing.pair gen₁ gen₂) = n

namespace BLSSetting

variable {A : Type u} [AddCommGroup A] {μ : Type v} [CommGroup μ] {n : ℕ}
  (S : BLSSetting A μ n)

/-- The root of unity `ζ = e(gen₁, gen₂)`. -/
def root : μ := S.pairing.pair S.gen₁ S.gen₂

/-- Public key for a secret scalar. -/
def publicKey (sk : ℕ) : A := sk • S.gen₂

/-- Hash-to-curve image of a message with hash exponent `h`. -/
def hashPoint (h : ℕ) : A := h • S.gen₁

/-- BLS signature. -/
def sign (sk h : ℕ) : A := (sk * h) • S.gen₁

/-- Pairing-based verification. -/
def verifies (pk H σ : A) : Prop := S.pairing.pair σ S.gen₂ = S.pairing.pair H pk

theorem pair_gen (a b : ℕ) :
    S.pairing.pair (a • S.gen₁) (b • S.gen₂) = S.root ^ (a * b) := by
  have hr : S.root = S.pairing.pair S.gen₁ S.gen₂ := rfl
  rw [S.pairing.pair_nsmul_left, S.pairing.pair_nsmul_right, ← pow_mul, hr,
    Nat.mul_comm]

theorem pair_sig (a : ℕ) : S.pairing.pair (a • S.gen₁) S.gen₂ = S.root ^ a := by
  have := S.pair_gen a 1
  simpa using this

theorem pair_hash_key (sk h : ℕ) :
    S.pairing.pair (S.hashPoint h) (S.publicKey sk) = S.root ^ (sk * h) := by
  show S.pairing.pair (h • S.gen₁) (sk • S.gen₂) = _
  rw [S.pair_gen, Nat.mul_comm]

/-- **Correctness.** -/
theorem verifies_sign (sk h : ℕ) :
    S.verifies (S.publicKey sk) (S.hashPoint h) (S.sign sk h) := by
  show S.pairing.pair _ S.gen₂ = S.pairing.pair _ _
  rw [sign, publicKey, hashPoint, S.pair_sig, S.pair_gen, Nat.mul_comm]

/-- **Exact characterisation of valid signatures.**  In the signature group `⟨gen₁⟩` the
verification equation holds precisely for the congruence class of the honest exponent;
this is the injectivity property that `BLSParams` tried, and failed, to impose. -/
theorem verifies_iff_modEq (sk h s : ℕ) :
    S.verifies (S.publicKey sk) (S.hashPoint h) (s • S.gen₁) ↔ s ≡ sk * h [MOD n] := by
  show S.pairing.pair _ S.gen₂ = S.pairing.pair _ _ ↔ _
  have hord : orderOf S.root = n := S.root_order
  rw [publicKey, hashPoint, S.pair_sig, S.pair_gen, pow_eq_pow_iff_modEq, hord,
    Nat.mul_comm]

/-- **Uniqueness of signatures.**  Any accepted signature in the signature group equals
the honest one. -/
theorem signature_unique (sk h s : ℕ)
    (hv : S.verifies (S.publicKey sk) (S.hashPoint h) (s • S.gen₁)) :
    s • S.gen₁ = S.sign sk h :=
  nsmul_eq_of_modEq S.torsion₁ ((S.verifies_iff_modEq sk h s).mp hv)

/-! ### CDH and existential unforgeability -/

/-- The fresh-message random-oracle programming event for the corrected setting: the
challenge secret is the signer's key, and the target message is programmed to the second
CDH input, which is fresh (never signed). -/
structure FreshGame (S : BLSSetting A μ n) (Message : Type*) [DecidableEq Message] where
  /-- the CDH secret exponent, also the signer's secret key -/
  secretA : ℕ
  /-- exponent of the programmed hash-to-curve oracle -/
  hashExp : Message → ℕ
  /-- the message the adversary must forge on -/
  targetMessage : Message
  /-- messages already queried to the signing oracle -/
  queried : Finset Message
  /-- freshness of the target message -/
  fresh : targetMessage ∉ queried

variable {S}

/-- The CDH target `sk • (h • gen₁)` of a fresh game. -/
def FreshGame.cdhTarget {Message : Type*} [DecidableEq Message]
    (game : FreshGame S Message) : A :=
  game.secretA • S.hashPoint (game.hashExp game.targetMessage)

/-- **EUF-CMA to CDH.**  Any signature accepted for the fresh programmed message *is* the
CDH solution. -/
theorem forgery_solves_cdh {Message : Type*} [DecidableEq Message]
    (game : FreshGame S Message) (s : ℕ)
    (valid : S.verifies (S.publicKey game.secretA)
      (S.hashPoint (game.hashExp game.targetMessage)) (s • S.gen₁)) :
    s • S.gen₁ = game.cdhTarget := by
  rw [S.signature_unique game.secretA (game.hashExp game.targetMessage) s valid]
  show (game.secretA * game.hashExp game.targetMessage) • S.gen₁ = _
  rw [FreshGame.cdhTarget, hashPoint, smul_smul]

/-- **Existential unforgeability under CDH.**  If the CDH target is outside the
adversary's attainable set, no attainable exponent yields a valid forgery on the fresh
message. -/
theorem no_forgery_of_cdh {Message : Type*} [DecidableEq Message]
    (game : FreshGame S Message) (attainable : A → Prop)
    (hard : ¬ attainable game.cdhTarget) :
    ¬ ∃ s : ℕ, attainable (s • S.gen₁) ∧
      S.verifies (S.publicKey game.secretA)
        (S.hashPoint (game.hashExp game.targetMessage)) (s • S.gen₁) := by
  rintro ⟨s, hatt, hvalid⟩
  exact hard (forgery_solves_cdh game s hvalid ▸ hatt)

/-! ### Aggregation -/

variable (S)

/-- Aggregate verification in the corrected setting. -/
def aggVerifies {ι : Type w} (s : Finset ι) (pk hash : ι → A) (σ : A) : Prop :=
  S.pairing.pair σ S.gen₂ = ∏ i ∈ s, S.pairing.pair (hash i) (pk i)

theorem pair_sum_sig {ι : Type w} (s : Finset ι) (c : ι → ℕ) :
    S.pairing.pair (∑ i ∈ s, c i • S.gen₁) S.gen₂ = S.root ^ (∑ i ∈ s, c i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha, S.pairing.pair_add_left, ih,
        S.pair_sig, pow_add]

/-- **Aggregate correctness.** -/
theorem aggVerifies_of_honest {ι : Type w} (s : Finset ι) (sk h : ι → ℕ) :
    S.aggVerifies s (fun i => S.publicKey (sk i)) (fun i => S.hashPoint (h i))
      (∑ i ∈ s, S.sign (sk i) (h i)) := by
  show S.pairing.pair _ S.gen₂ = _
  have hl : (∑ i ∈ s, S.sign (sk i) (h i)) = ∑ i ∈ s, (sk i * h i) • S.gen₁ := rfl
  rw [hl, S.pair_sum_sig,
    Finset.prod_congr rfl (fun i _ => S.pair_hash_key (sk i) (h i)),
    Finset.prod_pow_eq_pow_sum s (fun i => sk i * h i) S.root]

/-- **Aggregate-to-single forgery extraction** in the corrected setting: from an
aggregate signature accepted for the signer set `s`, an adversary knowing the co-signers'
keys obtains a valid single-signer signature for the target index. -/
theorem aggregate_forgery_extracts {ι : Type w} [DecidableEq ι] (s : Finset ι) (i₀ : ι)
    (hi₀ : i₀ ∈ s) (sk h : ι → ℕ) (t : ℕ)
    (hagg : S.aggVerifies s (fun i => S.publicKey (sk i)) (fun i => S.hashPoint (h i))
      (t • S.gen₁)) :
    S.verifies (S.publicKey (sk i₀)) (S.hashPoint (h i₀))
      (t • S.gen₁ - ∑ i ∈ s.erase i₀, S.sign (sk i) (h i)) := by
  have hprod : (∏ i ∈ s, S.pairing.pair (S.hashPoint (h i)) (S.publicKey (sk i)))
      = S.root ^ (∑ i ∈ s, sk i * h i) := by
    rw [Finset.prod_congr rfl (fun i _ => S.pair_hash_key (sk i) (h i)),
      Finset.prod_pow_eq_pow_sum s (fun i => sk i * h i) S.root]
  have ht : S.root ^ t = S.root ^ (∑ i ∈ s, sk i * h i) := by
    have := hagg
    rw [aggVerifies, S.pair_sig, hprod] at this
    exact this
  have hsplit : (∑ i ∈ s, sk i * h i)
      = sk i₀ * h i₀ + ∑ i ∈ s.erase i₀, sk i * h i :=
    (Finset.add_sum_erase s _ hi₀).symm
  have hco : S.pairing.pair (∑ i ∈ s.erase i₀, S.sign (sk i) (h i)) S.gen₂
      = S.root ^ (∑ i ∈ s.erase i₀, sk i * h i) := by
    have hl : (∑ i ∈ s.erase i₀, S.sign (sk i) (h i))
        = ∑ i ∈ s.erase i₀, (sk i * h i) • S.gen₁ := rfl
    rw [hl, S.pair_sum_sig]
  show S.pairing.pair _ S.gen₂ = S.pairing.pair _ _
  rw [S.pairing.pair_sub_left, S.pair_sig, hco, ht, hsplit, pow_add,
    mul_inv_cancel_right, S.pair_hash_key (sk i₀) (h i₀)]

/-! ### Batch verification -/

/-- Pairing turns a weighted sum of signatures into the weighted product of pairing
values. -/
theorem pair_sum_nsmul {ι : Type w} (s : Finset ι) (r : ι → ℕ) (sig : ι → A) :
    S.pairing.pair (∑ i ∈ s, r i • sig i) S.gen₂
      = ∏ i ∈ s, S.pairing.pair (sig i) S.gen₂ ^ (r i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.prod_insert ha, S.pairing.pair_add_left, ih,
        S.pairing.pair_nsmul_left]

/-- The batch verification equation with weights `r`. -/
def batchVerifies {ι : Type w} (s : Finset ι) (pk hash sig : ι → A) (r : ι → ℕ) : Prop :=
  S.pairing.pair (∑ i ∈ s, r i • sig i) S.gen₂
    = ∏ i ∈ s, S.pairing.pair (hash i) (pk i) ^ (r i)

/-- **Batch verification is sound and complete**: a family passes every weighted batch
check iff every signature verifies individually. -/
theorem batchVerifies_iff {ι : Type w} [DecidableEq ι] (s : Finset ι)
    (pk hash sig : ι → A) :
    (∀ r : ι → ℕ, S.batchVerifies s pk hash sig r)
      ↔ ∀ i ∈ s, S.verifies (pk i) (hash i) (sig i) := by
  constructor
  · intro hb i₀ hi₀
    have hsum : (∑ i ∈ s, (if i = i₀ then 1 else 0) • sig i) = sig i₀ := by
      simp [ite_smul, hi₀]
    have hprod : (∏ i ∈ s, S.pairing.pair (hash i) (pk i) ^ (if i = i₀ then 1 else 0))
        = S.pairing.pair (hash i₀) (pk i₀) := by
      simp [pow_ite, hi₀]
    have h2 : S.pairing.pair (∑ i ∈ s, (if i = i₀ then 1 else 0) • sig i) S.gen₂
        = ∏ i ∈ s, S.pairing.pair (hash i) (pk i) ^ (if i = i₀ then 1 else 0) :=
      hb (fun i => if i = i₀ then 1 else 0)
    rw [hsum, hprod] at h2
    exact h2
  · intro hv r
    show S.pairing.pair (∑ i ∈ s, r i • sig i) S.gen₂ = _
    rw [S.pair_sum_nsmul]
    exact Finset.prod_congr rfl fun i hi => congrArg (fun x => x ^ r i) (hv i hi)

/-! ### Quantitative shortness -/

section Compression

variable [Fintype A] [DecidableEq A]

omit [AddCommGroup A] [DecidableEq A] in
/-- The space of `m` separate signatures has `N ^ m` elements. -/
theorem signature_tuple_card (m : ℕ) :
    Fintype.card (Fin m → A) = Fintype.card A ^ m := by
  simp

/-- Aggregates are single group elements, so at most `N` of them occur. -/
theorem aggregate_image_card_le (m : ℕ) :
    ((Finset.univ : Finset (Fin m → A)).image fun v => ∑ i, v i).card
      ≤ Fintype.card A := by
  refine le_trans (Finset.card_le_card (Finset.subset_univ _)) (le_of_eq ?_)
  exact Finset.card_univ

/-- **Compression.**  For at least one signer, aggregation is exactly an `N ^ m ↠ N`
compression: every group element occurs as an aggregate, and the aggregate is a single
group element no matter how many signatures were combined. -/
theorem aggregate_compression (m : ℕ) (hm : 0 < m) :
    ((Finset.univ : Finset (Fin m → A)).image fun v => ∑ i, v i).card = Fintype.card A
      ∧ Fintype.card (Fin m → A) = Fintype.card A ^ m := by
  refine ⟨le_antisymm (aggregate_image_card_le m) ?_, signature_tuple_card m⟩
  have hsurj : ∀ g : A,
      g ∈ (Finset.univ : Finset (Fin m → A)).image fun v => ∑ i, v i := by
    intro g
    refine Finset.mem_image.mpr ⟨fun i => if i = ⟨0, hm⟩ then g else 0,
      Finset.mem_univ _, ?_⟩
    simp
  calc Fintype.card A = (Finset.univ : Finset A).card := rfl
    _ ≤ _ := Finset.card_le_card fun g _ => hsurj g

end Compression

/-! ### The rogue-key attack survives in the corrected setting -/

/-- The rogue public key, computed from the victim's public key alone. -/
def roguePublicKey (y : ℕ) (pk₁ : A) : A := y • S.gen₂ - pk₁

/-- **Rogue-key attack.**  Without key registration, the forger `σ = y • H` — which uses
no secret key — always satisfies the two-signer aggregate equation on a common message.
So the extraction theorem above genuinely needs registered (KOSK) keys. -/
theorem rogue_key_attack (y : ℕ) (pk₁ H : A) :
    S.aggVerifies (Finset.univ : Finset (Fin 2))
      (fun i => if i = 0 then pk₁ else S.roguePublicKey y pk₁) (fun _ => H) (y • H) := by
  show S.pairing.pair (y • H) S.gen₂ = _
  rw [Fin.prod_univ_two]
  norm_num [roguePublicKey]
  rw [← S.pairing.pair_add_right, add_sub_cancel, S.pairing.pair_nsmul_left,
    S.pairing.pair_nsmul_right]

end BLSSetting

/-! ## Part 3: the corrected setting is inhabited -/

/-- **Non-vacuity, determinant model.**  The corrected BLS setting exists for every
modulus `n ≥ 1`, on the group `(ZMod n)²` with the determinant (Weil) pairing. -/
def detBLSSetting (n : ℕ) [NeZero n] :
    BLSSetting (ZMod n × ZMod n) (Multiplicative (ZMod n)) n where
  pairing := detPairing n
  gen₁ := ((1 : ZMod n), (0 : ZMod n))
  gen₂ := ((0 : ZMod n), (1 : ZMod n))
  torsion₁ := by ext <;> simp [nsmul_eq_mul]
  root_order :=
    alt_pairing_orderOf_eq_of_nondegenerate (detPairing n)
      (multiplicative_zmod_pow_self n _) detPairing_nondegenerate_left

variable {F : Type u} [Field F] [DecidableEq F]

/-- Every `n`-torsion point is killed by `n`, inside the subgroup. -/
theorem torsionPoints_nsmul_eq_zero {W : WeierstrassCurve F} {n : ℕ}
    (x : torsionPoints W n) : n • x = 0 := by
  apply Subtype.ext
  have hx : n • (x : W.toAffine.Point) = 0 := x.2
  simpa using hx

/-- **Non-vacuity, curve model.**  Any Weierstrass curve whose `n`-torsion is isomorphic
to `(ZMod n)²` carries a corrected BLS setting, with the Weil pairing of
`weilPairingOfEquiv` and the images of the standard basis as the two generators. -/
def curveBLSSetting {W : WeierstrassCurve F} {n : ℕ} [NeZero n]
    (φ : torsionPoints W n ≃+ (ZMod n × ZMod n)) :
    BLSSetting (torsionPoints W n) (Multiplicative (ZMod n)) n where
  pairing := (weilPairingOfEquiv φ).toAltPairing
  gen₁ := φ.symm ((1 : ZMod n), (0 : ZMod n))
  gen₂ := φ.symm ((0 : ZMod n), (1 : ZMod n))
  torsion₁ := torsionPoints_nsmul_eq_zero _
  root_order := by
    have h : ((weilPairingOfEquiv φ).toAltPairing).pair
        (φ.symm ((1 : ZMod n), (0 : ZMod n))) (φ.symm ((0 : ZMod n), (1 : ZMod n)))
        = (detPairing n).pair ((1 : ZMod n), (0 : ZMod n)) ((0 : ZMod n), (1 : ZMod n)) := by
      show (detPairing n).pair (φ (φ.symm _)) (φ (φ.symm _)) = _
      rw [φ.apply_symm_apply, φ.apply_symm_apply]
    rw [h]
    exact (detBLSSetting n).root_order

end Cryptography.WeilBLS