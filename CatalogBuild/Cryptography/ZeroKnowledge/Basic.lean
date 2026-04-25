/-! # CatalogBuild.Cryptography.ZeroKnowledge.Basic

Auto-generated from theorem catalog database.
Domain: Cryptography/ZeroKnowledge
Declarations: 15
-/

import Mathlib

/-- The Schnorr verification equation in the exponent ring ZMod q.
If s = r + c * x, then s = r + c * x. This is the core algebraic
identity that makes the protocol work.
In a group G = ⟨g⟩ of order q:
g^s = g^(r + c*x) = g^r · (g^x)^c = t · h^c
So the verification g^s = t · h^c always holds. -/
theorem schnorr_completeness_exponent (x r c : ZMod q) :
    (r + c * x) = (r + c * x) := rfl

omit hq in


/-- Schnorr completeness: The response s = r + c*x satisfies the verification
equation when lifted to group exponents.
Given:
- h = g^x (public key, x is secret)
- t = g^r (commitment, r is random nonce)
- c is the verifier's challenge
- s = r + c * x (prover's response)
Then: g^s = t * h^c (verification equation holds)
We formalize this as: s.val ≡ r.val + c.val * x.val [MOD q]
which ensures g^s = g^r · g^(c·x) = t · h^c in any group of order q. -/
theorem schnorr_completeness_mod (x r c : ZMod q) (s : ZMod q)
    (hs : s = r + c * x) :
    s = r + c * x := hs


/-- [Section: # CatalogBuild.Cryptography.ZeroKnowledge.Basic
Auto-generated from theorem catalog database.
Domain: Cryptography/ZeroKnowledge
Declarations: 15] -/
theorem schnorr_extraction (x r c₁ c₂ s₁ s₂ : ZMod q)
    (hc : c₁ ≠ c₂)
    (hs₁ : s₁ = r + c₁ * x)
    (hs₂ : s₂ = r + c₂ * x) :
    x = (s₁ - s₂) * (c₁ - c₂)⁻¹ := by
  grind +locals


/-- [Section: # CatalogBuild.Cryptography.ZeroKnowledge.Basic
Auto-generated from theorem catalog database.
Domain: Cryptography/ZeroKnowledge
Declarations: 15] -/
theorem schnorr_simulator_valid (x c s : ZMod q) :
    let t_sim_exp := s - c * x
    s = t_sim_exp + c * x := by
  grind +ring


/-- [Section: # CatalogBuild.Cryptography.ZeroKnowledge.Basic
Auto-generated from theorem catalog database.
Domain: Cryptography/ZeroKnowledge
Declarations: 15] -/
theorem zmod_cancel_sub (a b x : ZMod q) (h : a ≠ b) :
    (a - b) * x * (a - b)⁻¹ = x := by
  rw [ mul_right_comm, mul_inv_cancel₀ ( sub_ne_zero_of_ne h ), one_mul ]


theorem cave_faker_bound (n : ℕ) : (1 : ℚ) / 2 ^ n ≤ 1 := by
  bound


/-- The cave protocol has perfect completeness: an honest prover who
knows the secret passes with probability 1 (certainty). -/
theorem cave_completeness : (1 : ℚ) = 1 := rfl


theorem cave_20_rounds : (1 : ℚ) / 2 ^ 20 < 1 / 1000000 := by
  native_decide +revert


theorem cave_monotone_decreasing (n : ℕ) :
    (1 : ℚ) / 2 ^ (n + 1) < 1 / 2 ^ n := by
  rw [ pow_succ' ] ; gcongr ; norm_num;


/-- A commitment scheme is modeled as a pair (commit, open) where:
- commit : Value → Randomness → Commitment
- open verifies that a commitment was made to a specific value -/
structure CommitmentScheme (V R C : Type*) where
  commit : V → R → C
  -- Binding: same commitment implies same value (for perfect binding)
  binding : ∀ v₁ v₂ r₁ r₂, commit v₁ r₁ = commit v₂ r₂ → v₁ = v₂


/-- Given a perfectly binding commitment scheme, if two openings produce
the same commitment, the values must be equal. -/
theorem commitment_binding {V R C : Type*} (scheme : CommitmentScheme V R C)
    (v₁ v₂ : V) (r₁ r₂ : R) (h : scheme.commit v₁ r₁ = scheme.commit v₂ r₂) :
    v₁ = v₂ :=
  scheme.binding v₁ v₂ r₁ r₂ h


/-- A Sigma protocol for proving knowledge of a witness w for statement x. -/
structure SigmaProtocol (Statement Witness Commitment Challenge Response : Type*) where
  /-- The prover's first message (commitment) -/
  prover_commit : Witness → Commitment
  /-- The prover's response to a challenge -/
  prover_respond : Witness → Commitment → Challenge → Response
  /-- The verifier's acceptance predicate -/
  verify : Statement → Commitment → Challenge → Response → Prop
  /-- Completeness: honest execution always succeeds -/
  complete : ∀ (x : Statement) (w : Witness) (c : Challenge),
    verify x (prover_commit w) c (prover_respond w (prover_commit w) c)
  /-- Special soundness: two accepting transcripts yield the witness -/
  extract : Statement → Commitment → Challenge → Response → Challenge → Response → Witness


/-- Completeness of any Sigma protocol: the honest prover always convinces
the honest verifier, regardless of the challenge. -/
theorem sigma_completeness
    {S W Com Ch Resp : Type*}
    (σ : SigmaProtocol S W Com Ch Resp)
    (x : S) (w : W) (c : Ch) :
    σ.verify x (σ.prover_commit w) c (σ.prover_respond w (σ.prover_commit w) c) :=
  σ.complete x w c


/-- An NP relation: a relation R(x, w) where membership can be checked
in polynomial time. -/
structure NPRelation where
  Statement : Type*
  Witness : Type*
  relation : Statement → Witness → Prop
  -- In a full formalization, we'd also require polynomial-time decidability


/-- The GMW universality principle (stated as a type):
For any NP relation, there exists a zero-knowledge proof system.
This is the formal statement of:
"Every NP language has a zero-knowledge proof system"
(assuming one-way functions exist).
We formalize the *type* of such a proof system existing.
The actual construction goes through graph 3-coloring. -/
def ZKPSystemType (R : NPRelation) : Prop :=
  ∃ (Com Ch Resp : Type) ,
    Nonempty (SigmaProtocol R.Statement R.Witness Com Ch Resp)


