import Mathlib
import Cryptography.SchnorrIdentification

/-!
# The Fiat–Shamir transform of Schnorr (non-interactive identification / signatures)

The **Fiat–Shamir transform** turns the interactive Schnorr Σ-protocol into a
*non-interactive* proof (the basis of Schnorr signatures) by deriving the verifier's
challenge deterministically from the commitment via a hash function `H`. This file
formalizes the transform on top of the catalog's `SchnorrIdentification` and shows that
all security content transfers from the interactive protocol.

We model the hash as an arbitrary function `H : ZMod p → ZMod p` (the random-oracle
abstraction at the syntactic level). A non-interactive proof is a pair `(t, s)`; the
verifier recomputes the challenge `c = H t` and accepts iff `s · g = t + (H t) · Y`.

## Main results

* `fs_completeness` — the honest non-interactive prover is accepted, for **any** hash `H`.
* `fs_sound_iff_interactive` — an FS proof `(t, s)` is accepting iff the interactive
  transcript `(t, H t, s)` is accepting; so the non-interactive verifier is exactly the
  interactive verifier with the challenge fixed by the oracle.
* `fs_special_soundness` — *forking extraction*: two accepting FS proofs sharing the
  commitment `t` but obtained under two oracle answers `c₁ ≠ c₂` at `t` (a "fork") recover
  the secret key `x = (c₁ − c₂)⁻¹ · (s₁ − s₂)`. This is the engine behind the Forking
  Lemma proof of EUF security for Schnorr signatures.
* `fs_unique_response` — for a fixed commitment and a fixed oracle answer the accepting
  response is unique, so the oracle answer fully determines an accepting proof's response.

-- !-- Lab Notes -- !--
Hypothesis (H3): Fiat–Shamir adds no algebraic content beyond fixing the challenge to
`H t`; soundness should reduce verbatim to interactive special soundness, with the only new
ingredient being the *fork* (two distinct oracle answers at the same commitment).
Experiment: phrase the non-interactive verifier as `accepts P Y (t, H t, s)` and prove the
iff with the catalog's `accepts`. Outcome: confirmed — `fs_sound_iff_interactive` is
definitional and `fs_special_soundness` is the catalog's `special_soundness` applied to the
two forked transcripts. Insight: the *only* place hardness enters is the assumption
`c₁ ≠ c₂`, which in the real reduction is supplied by rewinding/reprogramming the random
oracle; the algebra is challenge-agnostic. Failure analysis: an attempt to bake the random
oracle's distribution into the statement was abandoned as it belongs to the probabilistic
Forking Lemma layer, not the algebraic core targeted here; we keep `H` a free function so
the result holds for every oracle.
-/

namespace SchnorrFS

variable (P : SchnorrParams)

/-- A non-interactive Fiat–Shamir proof: commitment and response (the challenge is derived
from `t` by the hash, so it is not transmitted). -/
structure FSProof (P : SchnorrParams) where
  t : ZMod P.p
  s : ZMod P.p

/-- Non-interactive verifier: recompute the challenge `c = H t` and check the Schnorr
equation `s · g = t + (H t) · Y`. -/
def fsAccepts (H : ZMod P.p → ZMod P.p) (Y : ZMod P.p) (π : FSProof P) : Prop :=
  π.s * P.g = π.t + (H π.t) * Y

/-- The honest non-interactive prover: commit `t = r · g`, then respond
`s = r + (H t) · x` with the self-derived challenge. -/
def fsProve (H : ZMod P.p → ZMod P.p) (x r : ZMod P.p) : FSProof P :=
  ⟨r * P.g, r + (H (r * P.g)) * x⟩

/-- **Completeness of Fiat–Shamir.** The honest non-interactive prover is accepted against
its public key `P.pk x`, for every hash function `H`. -/
theorem fs_completeness (H : ZMod P.p → ZMod P.p) (x r : ZMod P.p) :
    fsAccepts P H (P.pk x) (fsProve P H x r) := by
  simp only [fsAccepts, fsProve, SchnorrParams.pk]
  ring

/-- **FS verification = interactive verification with the oracle-fixed challenge.** An FS
proof `(t, s)` is accepting iff the interactive transcript `(t, H t, s)` is accepting. -/
theorem fs_sound_iff_interactive (H : ZMod P.p → ZMod P.p) (Y : ZMod P.p) (π : FSProof P) :
    fsAccepts P H Y π ↔ accepts P Y (π.t, H π.t, π.s) := by
  rfl

/-- **Forking extraction (special soundness of Fiat–Shamir).** Two accepting FS proofs
sharing commitment `t`, obtained under oracle answers `c₁ ≠ c₂` at `t` — i.e. acceptance
holds for the two challenges `c₁, c₂` — recover the secret key. This is the algebraic core
of the Forking Lemma security proof for Schnorr signatures. -/
theorem fs_special_soundness (x t c₁ s₁ c₂ s₂ : ZMod P.p)
    (h₁ : s₁ * P.g = t + c₁ * P.pk x)
    (h₂ : s₂ * P.g = t + c₂ * P.pk x)
    (hc : c₁ ≠ c₂) :
    x = (c₁ - c₂)⁻¹ * (s₁ - s₂) :=
  special_soundness P x t c₁ s₁ c₂ s₂ h₁ h₂ hc

/-- **Unique response.** For a fixed commitment `t`, public key `Y`, and oracle answer
`c` (used as the challenge), there is at most one accepting response. Hence an accepting FS
proof's response is determined by `(t, c, Y)`. -/
theorem fs_unique_response (H : ZMod P.p → ZMod P.p) (Y : ZMod P.p) (π π' : FSProof P)
    (ht : π.t = π'.t) (h₁ : fsAccepts P H Y π) (h₂ : fsAccepts P H Y π') :
    π.s = π'.s := by
  simp only [fsAccepts, ht] at h₁ h₂
  have : π.s * P.g = π'.s * P.g := by rw [h₁, h₂]
  exact mul_right_cancel₀ P.hg this

end SchnorrFS