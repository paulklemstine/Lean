import Cryptography.WeilPairingStructure

/-!
# Aggregate BLS signatures: extraction, security reduction, rogue keys and compression

Building on the catalog file `Cryptography.WeilPairingBLS` (which sets up `BLSParams`,
single-signature correctness and the EUF-CMA-to-CDH reduction for one signer) this file
develops the *aggregate* theory.

Main results.

* `BLSParams.aggVerifies` : the aggregate verification equation
  `e(σ, G) = ∏ e(H i, pk i)`.
* `BLSParams.aggVerifies_of_honest` : correctness of aggregation.
* `BLSParams.aggregate_signature_unique` : in the registered-key (KOSK) setting the
  aggregate verification equation has a **unique** solution, `σ = ∑ sk i • H i`.
* `BLSParams.aggregate_forgery_extracts` : from any aggregate forgery, an adversary that
  knows the co-signers' keys **extracts a single-signer BLS forgery**.  This is the
  standard aggregate-to-plain security reduction, formalised.
* `BLSParams.aggregate_forgery_solves_cdh` and
  `BLSParams.no_aggregate_forgery_of_cdh` : chaining the extraction with the catalog's
  fresh-message programming lemma, an aggregate forgery *is* the CDH solution, so
  aggregate EUF-CMA reduces to CDH.
* `BLSParams.rogue_key_attack` : the reduction above genuinely needs registered keys.
  Without them the scheme is **broken**: an explicit forger, knowing no secret key,
  produces a valid two-signer aggregate for an honest victim key.
* `BLSParams.aggregate_compression` : the quantitative shortness statement.  The space of
  `m`-tuples of signatures has `N ^ m` elements while every aggregate is one of the `N`
  group elements — and for `m ≥ 1` all of them occur, so aggregation is exactly an
  `N ^ m → N` compression.
**Caveat found in adversarial review.**  The catalog structure `BLSParams` carries the
axiom `Function.Injective (fun P => pairing.pair P generator)`, which
`Cryptography.BLSCorrected` proves is satisfiable only for trivial `n`-torsion.  The
results below are therefore stated over a degenerate model; every one of them is
re-proved over the satisfiable asymmetric model `BLSSetting` in
`Cryptography.BLSCorrected`.
-/

open scoped BigOperators
open Finset

namespace Cryptography.WeilBLS

universe u v

variable {F : Type u} [Field F] [DecidableEq F] {W : WeierstrassCurve F} {n : ℕ}
  {μ : Type v} [CommGroup μ]

namespace WeilPairing

variable (e : WeilPairing W n μ)

theorem pair_sub_left (P Q R : torsionPoints W n) :
    e.pair (P - Q) R = e.pair P R * (e.pair Q R)⁻¹ :=
  e.toAltPairing.pair_sub_left P Q R

end WeilPairing

/-! ## Aggregate verification -/

namespace BLSParams

variable (P : BLSParams W n μ)

/-- The aggregate BLS verification equation: one group element `σ` is checked against a
product of pairings, one per signer. -/
def aggVerifies {ι : Type*} (s : Finset ι) (pk hash : ι → torsionPoints W n)
    (σ : torsionPoints W n) : Prop :=
  P.pairing.pair σ P.generator = ∏ i ∈ s, P.pairing.pair (hash i) (pk i)

/-- **Aggregate correctness.**  The sum of honest signatures verifies. -/
theorem aggVerifies_of_honest {ι : Type*} (s : Finset ι) (sk : ι → ℕ)
    (hash : ι → torsionPoints W n) :
    P.aggVerifies s (fun i => P.publicKey (sk i)) hash
      (aggregate s fun i => P.sign (sk i) (hash i)) :=
  P.aggregate_verifies s sk hash

/-- **Uniqueness of the aggregate.**  With registered keys the verification equation
determines the aggregate signature completely: there is no room for an alternative
witness.  (This is the KOSK/proof-of-possession model.) -/
theorem aggregate_signature_unique {ι : Type*} (s : Finset ι) (sk : ι → ℕ)
    (hash : ι → torsionPoints W n) (σ : torsionPoints W n)
    (hσ : P.aggVerifies s (fun i => P.publicKey (sk i)) hash σ) :
    σ = aggregate s fun i => P.sign (sk i) (hash i) := by
  apply P.pairing_generator_injective
  change P.pairing.pair σ P.generator
    = P.pairing.pair (aggregate s fun i => P.sign (sk i) (hash i)) P.generator
  rw [hσ, P.aggregate_verifies s sk hash]

/-- **Aggregate-to-single forgery extraction.**  An adversary that produces a valid
aggregate signature for a signer set `s`, while knowing the secret keys of all
co-signers, obtains a valid single-signer BLS signature for the target index `i₀`.  No
assumption is made on how `σ` was produced. -/
theorem aggregate_forgery_extracts {ι : Type*} [DecidableEq ι] (s : Finset ι) (i₀ : ι)
    (hi₀ : i₀ ∈ s) (sk : ι → ℕ) (hash : ι → torsionPoints W n) (σ : torsionPoints W n)
    (hσ : P.aggVerifies s (fun i => P.publicKey (sk i)) hash σ) :
    P.verifies (P.publicKey (sk i₀)) (hash i₀)
      (σ - aggregate (s.erase i₀) fun i => P.sign (sk i) (hash i)) := by
  have hcos : P.pairing.pair (aggregate (s.erase i₀) fun i => P.sign (sk i) (hash i))
      P.generator
      = ∏ i ∈ s.erase i₀, P.pairing.pair (hash i) (P.publicKey (sk i)) :=
    P.aggregate_verifies (s.erase i₀) sk hash
  have hsplit : P.pairing.pair (hash i₀) (P.publicKey (sk i₀)) *
      ∏ i ∈ s.erase i₀, P.pairing.pair (hash i) (P.publicKey (sk i))
      = ∏ i ∈ s, P.pairing.pair (hash i) (P.publicKey (sk i)) :=
    Finset.mul_prod_erase s (fun i => P.pairing.pair (hash i) (P.publicKey (sk i))) hi₀
  show P.pairing.pair _ P.generator = _
  rw [P.pairing.pair_sub_left, hσ, hcos, ← hsplit, mul_inv_cancel_right]

/-- **Aggregate EUF-CMA reduces to CDH.**  Combining forgery extraction with the
catalog's fresh-message oracle programming: any valid aggregate signature involving the
challenge key on the programmed message yields exactly the CDH target. -/
theorem aggregate_forgery_solves_cdh {Message : Type*} [DecidableEq Message]
    {ι : Type*} [DecidableEq ι] (game : ProgrammedFreshChallenge P Message)
    (s : Finset ι) (i₀ : ι) (hi₀ : i₀ ∈ s) (sk : ι → ℕ)
    (hash : ι → torsionPoints W n) (σ : torsionPoints W n)
    (hkey : sk i₀ = game.challenge.secretA)
    (hmsg : hash i₀ = game.hashToCurve game.targetMessage)
    (hσ : P.aggVerifies s (fun i => P.publicKey (sk i)) hash σ) :
    σ - (aggregate (s.erase i₀) fun i => P.sign (sk i) (hash i)) = game.challenge.target := by
  have hval := P.aggregate_forgery_extracts s i₀ hi₀ sk hash σ hσ
  rw [hkey, hmsg] at hval
  refine P.forgery_solves_cdh game _ ?_
  rw [game.challenge.publicA_eq]
  exact hval

/-- **No aggregate forgery under CDH.**  If the CDH target is unattainable for the
adversary's output class (closed under subtracting the known co-signer contributions),
then no valid aggregate signature involving the challenge key is attainable. -/
theorem no_aggregate_forgery_of_cdh {Message : Type*} [DecidableEq Message]
    {ι : Type*} [DecidableEq ι] (game : ProgrammedFreshChallenge P Message)
    (s : Finset ι) (i₀ : ι) (hi₀ : i₀ ∈ s) (sk : ι → ℕ)
    (hash : ι → torsionPoints W n)
    (hkey : sk i₀ = game.challenge.secretA)
    (hmsg : hash i₀ = game.hashToCurve game.targetMessage)
    (attainable : torsionPoints W n → Prop)
    (hclosed : ∀ σ, attainable σ →
      attainable (σ - aggregate (s.erase i₀) fun i => P.sign (sk i) (hash i)))
    (hard : CDHHardFor P game.challenge attainable) :
    ¬ ∃ σ, attainable σ ∧ P.aggVerifies s (fun i => P.publicKey (sk i)) hash σ := by
  rintro ⟨σ, hatt, hσ⟩
  apply hard
  rw [← P.aggregate_forgery_solves_cdh game s i₀ hi₀ sk hash σ hkey hmsg hσ]
  exact hclosed σ hatt

/-! ## The rogue-key attack: registration is necessary -/

/-- The rogue public key `y • G - pk₁`, computed by an adversary from a chosen scalar
`y` and the *victim's public key alone*. -/
def roguePublicKey (y : ℕ) (pk₁ : torsionPoints W n) : torsionPoints W n :=
  y • P.generator - pk₁

/-- **Rogue-key attack.**  For the two-signer aggregate on a common message `H`, the
forged signature `y • H` — computable from `y` and `H` only, with no secret key and no
interaction with the victim — satisfies the aggregate verification equation for the key
pair `(pk₁, roguePublicKey y pk₁)`.  Hence plain aggregation is existentially forgeable,
and the reduction `aggregate_forgery_solves_cdh` really does need registered keys. -/
theorem rogue_key_attack (y : ℕ) (pk₁ H : torsionPoints W n) :
    P.aggVerifies (Finset.univ : Finset (Fin 2))
      (fun i => if i = 0 then pk₁ else P.roguePublicKey y pk₁) (fun _ => H) (y • H) := by
  show P.pairing.pair (y • H) P.generator = _
  rw [Fin.prod_univ_two]
  norm_num [roguePublicKey]
  rw [← P.pairing.pair_add_right, add_sub_cancel, P.pairing.bilinear_left,
    P.pairing.bilinear_right]

/-- The forger of `rogue_key_attack` is a *single* function of the chosen scalar and the
message hash: it is independent of the victim's public key, so it uses no secret
information whatsoever. -/
theorem rogue_key_attack_universal :
    ∃ forge : ℕ → torsionPoints W n → torsionPoints W n,
      ∀ (y : ℕ) (pk₁ H : torsionPoints W n),
        P.aggVerifies (Finset.univ : Finset (Fin 2))
          (fun i => if i = 0 then pk₁ else P.roguePublicKey y pk₁) (fun _ => H)
          (forge y H) :=
  ⟨fun y H => y • H, fun y pk₁ H => P.rogue_key_attack y pk₁ H⟩

/-! ## Batch verification -/

/-- Pairing turns a randomised linear combination of signatures into the corresponding
weighted product of pairing values. -/
theorem pair_sum_nsmul {ι : Type*} (s : Finset ι) (r : ι → ℕ)
    (sig : ι → torsionPoints W n) :
    P.pairing.pair (∑ i ∈ s, r i • sig i) P.generator
      = ∏ i ∈ s, P.pairing.pair (sig i) P.generator ^ (r i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.prod_insert ha, P.pairing.pair_add_left, ih,
        P.pairing.bilinear_left]

/-- The batch verification equation with weights `r`. -/
def batchVerifies {ι : Type*} (s : Finset ι) (pk hash sig : ι → torsionPoints W n)
    (r : ι → ℕ) : Prop :=
  P.pairing.pair (∑ i ∈ s, r i • sig i) P.generator
    = ∏ i ∈ s, P.pairing.pair (hash i) (pk i) ^ (r i)

/-- **Soundness and completeness of batch verification.**  A family of signatures passes
*every* weighted batch check if and only if each signature verifies individually; the
"only if" direction uses the indicator weights, which is the deterministic core of the
usual randomised batch-verification argument. -/
theorem batchVerifies_iff {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (pk hash sig : ι → torsionPoints W n) :
    (∀ r : ι → ℕ, P.batchVerifies s pk hash sig r)
      ↔ ∀ i ∈ s, P.verifies (pk i) (hash i) (sig i) := by
  constructor
  · intro h i₀ hi₀
    have hr := h (fun i => if i = i₀ then 1 else 0)
    have hsum : (∑ i ∈ s, (if i = i₀ then 1 else 0) • sig i) = sig i₀ := by
      simp [ite_smul, hi₀]
    have hprod : (∏ i ∈ s, P.pairing.pair (hash i) (pk i) ^ (if i = i₀ then 1 else 0))
        = P.pairing.pair (hash i₀) (pk i₀) := by
      simp [pow_ite, hi₀]
    have h2 : P.pairing.pair (∑ i ∈ s, (if i = i₀ then 1 else 0) • sig i) P.generator
        = ∏ i ∈ s, P.pairing.pair (hash i) (pk i) ^ (if i = i₀ then 1 else 0) := hr
    rw [hsum, hprod] at h2
    exact h2
  · intro h r
    show P.pairing.pair (∑ i ∈ s, r i • sig i) P.generator = _
    rw [P.pair_sum_nsmul]
    exact Finset.prod_congr rfl fun i hi => congrArg (fun x => x ^ r i) (h i hi)

/-! ## Quantitative shortness -/

section Compression

variable [Fintype (torsionPoints W n)] [DecidableEq (torsionPoints W n)]

omit [DecidableEq (torsionPoints W n)] in
/-- The space of `m` separate signatures has `N ^ m` elements. -/
theorem signature_tuple_card (m : ℕ) :
    Fintype.card (Fin m → torsionPoints W n) = Fintype.card (torsionPoints W n) ^ m := by
  simp

/-- Every aggregate is a single group element, so at most `N` values occur. -/
theorem aggregate_image_card_le (m : ℕ) :
    ((Finset.univ : Finset (Fin m → torsionPoints W n)).image
        fun v => aggregate Finset.univ v).card ≤ Fintype.card (torsionPoints W n) := by
  refine le_trans (Finset.card_le_card (Finset.subset_univ _)) (le_of_eq ?_)
  exact Finset.card_univ

/-- For at least one signer every group element occurs as an aggregate, so aggregation is
an exactly `N ^ m ↠ N` compression: the aggregate is as short as a single signature and
no shorter representation of the verification data is being hidden. -/
theorem aggregate_image_card_eq (m : ℕ) (hm : 0 < m) :
    ((Finset.univ : Finset (Fin m → torsionPoints W n)).image
        fun v => aggregate Finset.univ v).card = Fintype.card (torsionPoints W n) := by
  refine le_antisymm (aggregate_image_card_le m) ?_
  have hsurj : ∀ g : torsionPoints W n, g ∈ (Finset.univ :
      Finset (Fin m → torsionPoints W n)).image fun v => aggregate Finset.univ v := by
    intro g
    refine Finset.mem_image.mpr ⟨fun i => if i = ⟨0, hm⟩ then g else 0, Finset.mem_univ _, ?_⟩
    simp [aggregate, Finset.sum_ite_eq' Finset.univ (⟨0, hm⟩ : Fin m) (fun _ => g)]
  calc Fintype.card (torsionPoints W n)
      = (Finset.univ : Finset (torsionPoints W n)).card := rfl
    _ ≤ _ := Finset.card_le_card fun g _ => hsurj g

/-- **Compression.**  Aggregation maps the exponentially large space of signature tuples
onto the fixed-size group. -/
theorem aggregate_compression (m : ℕ) (hm : 0 < m) :
    ((Finset.univ : Finset (Fin m → torsionPoints W n)).image
        fun v => aggregate Finset.univ v).card = Fintype.card (torsionPoints W n) ∧
      Fintype.card (Fin m → torsionPoints W n) = Fintype.card (torsionPoints W n) ^ m :=
  ⟨aggregate_image_card_eq m hm, signature_tuple_card m⟩

end Compression

end BLSParams

end Cryptography.WeilBLS