/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Cryptography.ZeroKnowledge.SchnorrGroupProtocol

/-!
# Fiat–Shamir for group-model Schnorr, and its analysis in the random-oracle model

Building on `Cryptography.ZeroKnowledge.SchnorrGroupProtocol` (the faithful cyclic-group
model of the Schnorr Σ-protocol), this file performs the **Fiat–Shamir transform**: the
verifier's challenge is replaced by the value of a hash function `H` on the statement, the
commitment and the message, turning the protocol into a non-interactive proof — a Schnorr
signature.

The random oracle is modelled as an arbitrary function `H : G × G × M → ZMod q`; the two
random-oracle techniques are formalised explicitly:

* **programmability** (`fs_sim_accepts`, `progOracle_agrees_off`): the zero-knowledge
  simulator reprograms `H` at the single point `(pub, a, m)` it invented, and its output is
  then a valid proof; the reprogrammed oracle is indistinguishable from `H` for anyone who
  never queries that point.
* **rewinding / forking** (`fs_forking_extraction`, `fs_fork_update_extraction`): two
  accepting proofs sharing a commitment but obtained under two oracle answers extract the
  secret key, which is exactly the algebraic engine of the Forking Lemma.

## Main results

* `fs_completeness` — the honest non-interactive prover is accepted for **every** oracle.
* `fs_accepts_iff_interactive` — Fiat–Shamir verification *is* interactive verification with
  the challenge fixed to the oracle's answer.
* `fs_forking_extraction`, `fs_fork_update_extraction` — forking extraction of the witness.
* `fs_sim_accepts`, `progOracle_agrees_off` — the programmed simulator produces accepting
  proofs and only touches the oracle at one point.
* `fs_zk_pmf` — perfect zero knowledge of the transform against a uniformly random oracle
  answer: honest and simulated transcript distributions are equal.
* `rom_forgery_bound` — an adversary that fixes `(a, z)` before the oracle answers at
  `(pub, a, m)` forges with probability at most `1 / q`.
* `rom_union_bound` — an adversary making `Q` oracle queries and precommitting to one
  candidate response per query forges with probability at most `Q / q`.
-/

namespace SchnorrGrp

variable {G : Type*} [CommGroup G] {q : ℕ} {M : Type*}

/-- A non-interactive Fiat–Shamir proof: a commitment and a response.  The challenge is not
transmitted since the verifier recomputes it from the oracle. -/
@[ext]
structure FSProof (G : Type*) (q : ℕ) where
  /-- The commitment. -/
  a : G
  /-- The response. -/
  z : ZMod q

/-- The Fiat–Shamir verifier: recompute the challenge `H (pub, a, m)` and run the
interactive verifier on the resulting transcript. -/
def FSAccepts (g pub : G) (H : G × G × M → ZMod q) (m : M) (π : FSProof G q) : Prop :=
  Accepts g pub ⟨π.a, H (pub, π.a, m), π.z⟩

/-- The honest non-interactive prover: commit to `g ^ r`, hash, and respond. -/
def fsProve (g : G) (H : G × G × M → ZMod q) (m : M) (x r : ZMod q) : FSProof G q :=
  ⟨gexp g r, r + H (gexp g x, gexp g r, m) * x⟩

/-- **Completeness of Fiat–Shamir.** For every hash function `H`, every message and every
randomness, the honest prover's non-interactive proof is accepted. -/
theorem fs_completeness [NeZero q] {g : G} (hg : g ^ q = 1) (H : G × G × M → ZMod q) (m : M)
    (x r : ZMod q) :
    FSAccepts g (gexp g x) H m (fsProve g H m x r) :=
  completeness hg x r _

/-- Fiat–Shamir verification is exactly interactive verification with the challenge fixed by
the oracle. -/
theorem fs_accepts_iff_interactive (g pub : G) (H : G × G × M → ZMod q) (m : M)
    (π : FSProof G q) :
    FSAccepts g pub H m π ↔ Accepts g pub ⟨π.a, H (pub, π.a, m), π.z⟩ := Iff.rfl

/-! ### Forking: witness extraction in the random-oracle model -/

/-- **Forking extraction.** Two accepting Fiat–Shamir proofs with the same commitment,
produced under two random oracles that answer differently at `(pub, a, m)`, yield a discrete
logarithm of the public key. -/
theorem fs_forking_extraction [Fact q.Prime] {g pub : G} (hg : g ^ q = 1) (hpub : pub ^ q = 1)
    (H₁ H₂ : G × G × M → ZMod q) (m : M) (π₁ π₂ : FSProof G q)
    (ha : π₁.a = π₂.a)
    (hacc₁ : FSAccepts g pub H₁ m π₁) (hacc₂ : FSAccepts g pub H₂ m π₂)
    (hfork : H₁ (pub, π₁.a, m) ≠ H₂ (pub, π₂.a, m)) :
    gexp g (extract (H₁ (pub, π₁.a, m)) π₁.z (H₂ (pub, π₂.a, m)) π₂.z) = pub := by
  refine special_soundness_witness hg hpub π₁.a _ _ _ _ hacc₁ ?_ hfork
  rw [ha]
  exact hacc₂

open scoped Classical in
/-- The same statement in the shape used by the Forking Lemma: the second run uses the oracle
`H` reprogrammed at the forking point to a fresh value `c₂`. -/
theorem fs_fork_update_extraction [Fact q.Prime] {g pub : G} (hg : g ^ q = 1)
    (hpub : pub ^ q = 1) (H : G × G × M → ZMod q) (m : M) (a : G) (z₁ z₂ c₂ : ZMod q)
    (hacc₁ : FSAccepts g pub H m ⟨a, z₁⟩)
    (hacc₂ : FSAccepts g pub (Function.update H (pub, a, m) c₂) m ⟨a, z₂⟩)
    (hfork : H (pub, a, m) ≠ c₂) :
    gexp g (extract (H (pub, a, m)) z₁ c₂ z₂) = pub := by
  refine special_soundness_witness hg hpub a _ _ _ _ hacc₁ ?_ hfork
  simpa [FSAccepts] using hacc₂

/-! ### Programming the random oracle: zero knowledge of the transform -/

/-- The simulator's non-interactive proof for a chosen challenge `c` and response `z`. -/
def fsSimulate (g pub : G) (c z : ZMod q) : FSProof G q :=
  ⟨gexp g z * (gexp pub c)⁻¹, z⟩

open scoped Classical in
/-- The oracle reprogrammed at the single point invented by the simulator. -/
noncomputable def progOracle (pub : G) (H : G × G × M → ZMod q) (m : M) (c z : ZMod q)
    (g : G) : G × G × M → ZMod q :=
  Function.update H (pub, (fsSimulate g pub c z).a, m) c

open scoped Classical in
/-- **Zero knowledge via a programmed oracle.** The witness-free simulator, allowed to
program the random oracle at the single point it invented, always produces an accepting
non-interactive proof. -/
theorem fs_sim_accepts (g pub : G) (H : G × G × M → ZMod q) (m : M) (c z : ZMod q) :
    FSAccepts g pub (progOracle pub H m c z g) m (fsSimulate g pub c z) := by
  have h : progOracle pub H m c z g (pub, (fsSimulate g pub c z).a, m) = c := by
    simp [progOracle]
  simpa [FSAccepts, h] using simulate_accepts g pub c z

open scoped Classical in
/-- The programmed oracle differs from the original one only at the point the simulator
invented: any distinguisher that never queries that point sees the true random oracle. -/
theorem progOracle_agrees_off (g pub : G) (H : G × G × M → ZMod q) (m : M) (c z : ZMod q)
    (y : G × G × M) (hy : y ≠ (pub, (fsSimulate g pub c z).a, m)) :
    progOracle pub H m c z g y = H y :=
  Function.update_of_ne hy _ _

/-- The joint randomness bijection `(r, c) ↦ (r + c * x, c)`. -/
def fsZKEquiv (x : ZMod q) : ZMod q × ZMod q ≃ ZMod q × ZMod q where
  toFun rc := (rc.1 + rc.2 * x, rc.2)
  invFun zc := (zc.1 - zc.2 * x, zc.2)
  left_inv := by intro rc; simp
  right_inv := by intro zc; simp

/-- **Perfect zero knowledge against a uniformly random oracle answer.** Over a uniform
challenge (the random oracle's answer at a fresh point) and uniform prover randomness, the
honest transcript distribution equals the simulator's distribution over a uniform challenge
and a uniform response.  Since the simulator uses no witness, Fiat–Shamir–Schnorr is
perfectly zero knowledge in the programmable random-oracle model. -/
theorem fs_zk_pmf [NeZero q] {g : G} (hg : g ^ q = 1) (x : ZMod q) :
    (PMF.uniformOfFintype (ZMod q × ZMod q)).map (fun rc => honest g x rc.1 rc.2)
      = (PMF.uniformOfFintype (ZMod q × ZMod q)).map
          (fun zc => simulate g (gexp g x) zc.2 zc.1) := by
  have h : (fun rc : ZMod q × ZMod q => honest g x rc.1 rc.2)
      = (fun zc : ZMod q × ZMod q => simulate g (gexp g x) zc.2 zc.1) ∘ (fsZKEquiv x) := by
    funext rc
    exact honest_eq_simulate hg x rc.1 rc.2
  rw [h, ← PMF.map_comp, map_uniformOfFintype_equiv]

/-! ### Quantitative security in the random-oracle model -/

open scoped Classical in
/-- **Random-oracle forgery bound.** An adversary that commits to a proof `(a, z)` before
learning the oracle's answer at `(pub, a, m)` is accepted for at most one of the `q` possible
answers, hence forges with probability at most `1 / q`. -/
theorem rom_forgery_bound [Fact q.Prime] {g pub : G} (hpub : pub ^ q = 1) (hpub1 : pub ≠ 1)
    (H : G × G × M → ZMod q) (m : M) (a : G) (z : ZMod q) :
    ((Finset.univ.filter (fun c : ZMod q =>
        FSAccepts g pub (Function.update H (pub, a, m) c) m ⟨a, z⟩)).card : ℚ)
        / (Finset.univ : Finset (ZMod q)).card ≤ 1 / q := by
  have hset : (Finset.univ.filter (fun c : ZMod q =>
      FSAccepts g pub (Function.update H (pub, a, m) c) m ⟨a, z⟩))
      = Finset.univ.filter (fun c : ZMod q => Accepts g pub ⟨a, c, z⟩) := by
    apply Finset.filter_congr
    intro c _
    simp [FSAccepts]
  rw [hset]
  exact soundness_error_le hpub hpub1 a z

open scoped Classical in
/-- Fixing one coordinate of a function `Fin Q → ZMod q` leaves exactly a `1 / q` fraction of
all such functions. -/
theorem card_filter_apply_eq [NeZero q] {Q : ℕ} (i : Fin Q) (v : ZMod q) :
    (Finset.univ.filter (fun f : Fin Q → ZMod q => f i = v)).card * q
      = Fintype.card (Fin Q → ZMod q) := by
  classical
  have key : ∀ w : ZMod q,
      (Finset.univ.filter (fun f : Fin Q → ZMod q => f i = w)).card
        = (Finset.univ.filter (fun f : Fin Q → ZMod q => f i = v)).card := by
    intro w
    refine Finset.card_bij (fun f _ => Function.update f i v) ?_ ?_ ?_
    · intro f _; simp
    · intro f₁ h₁ f₂ h₂ he
      simp only [Finset.mem_filter] at h₁ h₂
      funext j
      by_cases hj : j = i
      · subst hj; rw [h₁.2, h₂.2]
      · have h3 := congrFun he j
        simp only [Function.update_of_ne hj] at h3
        exact h3
    · intro f hf
      simp only [Finset.mem_filter] at hf
      exact ⟨Function.update f i w, by simp, by
        funext j
        by_cases hj : j = i
        · subst hj; simp [hf.2]
        · simp [Function.update_of_ne hj]⟩
  have hcards : Fintype.card (Fin Q → ZMod q)
      = ∑ w : ZMod q, (Finset.univ.filter (fun f : Fin Q → ZMod q => f i = w)).card := by
    rw [← Finset.card_univ]
    exact Finset.card_eq_sum_card_fiberwise (fun f _ => Finset.mem_univ (f i))
  rw [hcards]
  simp only [key]
  rw [Finset.sum_const, smul_eq_mul, Finset.card_univ, ZMod.card, mul_comm]

open scoped Classical in
/-- **Union bound over `Q` random-oracle queries.** Suppose an adversary makes `Q` oracle
queries, precommitting to a commitment `a i` and a response `z i` for each, and wins if any
of the `Q` resulting proofs verifies.  Over a uniformly random oracle (a uniform vector of
answers) its success probability is at most `Q / q`.  This is the standard random-oracle
security bound for Fiat–Shamir–Schnorr. -/
theorem rom_union_bound [Fact q.Prime] {g pub : G} (hpub : pub ^ q = 1) (hpub1 : pub ≠ 1)
    (Q : ℕ) (a : Fin Q → G) (z : Fin Q → ZMod q) :
    ((Finset.univ.filter (fun f : Fin Q → ZMod q =>
        ∃ i, Accepts g pub ⟨a i, f i, z i⟩)).card : ℚ)
        / (Fintype.card (Fin Q → ZMod q)) ≤ Q / q := by
  classical
  set N := Fintype.card (Fin Q → ZMod q) with hN
  set S := Finset.univ.filter (fun f : Fin Q → ZMod q => ∃ i, Accepts g pub ⟨a i, f i, z i⟩)
    with hS
  set T := fun i : Fin Q =>
    Finset.univ.filter (fun f : Fin Q → ZMod q => Accepts g pub ⟨a i, f i, z i⟩) with hT
  -- each `T i` occupies at most a `1/q` fraction
  have hTi : ∀ i, (T i).card * q ≤ N := by
    intro i
    obtain ⟨c₀, hc₀⟩ := Finset.card_le_one_iff_subset_singleton.mp
      (accepting_challenges_card_le_one hpub hpub1 (a i) (z i))
    have hsub : T i ⊆ Finset.univ.filter (fun f : Fin Q → ZMod q => f i = c₀) := by
      intro f hf
      simp only [hT, Finset.mem_filter] at hf
      have : f i ∈ Finset.univ.filter (fun c : ZMod q => Accepts g pub ⟨a i, c, z i⟩) := by
        simp [hf.2]
      simpa using hc₀ this
    calc (T i).card * q
        ≤ (Finset.univ.filter (fun f : Fin Q → ZMod q => f i = c₀)).card * q :=
          Nat.mul_le_mul_right _ (Finset.card_le_card hsub)
      _ = N := card_filter_apply_eq i c₀
  -- union bound
  have hSsub : S ⊆ Finset.univ.biUnion T := by
    intro f hf
    simp only [hS, Finset.mem_filter] at hf
    obtain ⟨i, hi⟩ := hf.2
    exact Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ i, by simp [hT, hi]⟩
  have hcard : S.card * q ≤ Q * N := by
    have h1 : S.card ≤ ∑ i : Fin Q, (T i).card :=
      le_trans (Finset.card_le_card hSsub) (Finset.card_biUnion_le)
    calc S.card * q ≤ (∑ i : Fin Q, (T i).card) * q := Nat.mul_le_mul_right _ h1
      _ = ∑ i : Fin Q, (T i).card * q := by rw [Finset.sum_mul]
      _ ≤ ∑ _i : Fin Q, N := Finset.sum_le_sum (fun i _ => hTi i)
      _ = Q * N := by rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul]
  -- convert to rationals
  have hq : (0 : ℚ) < q := by exact_mod_cast (Fact.out : q.Prime).pos
  have hNpos : (0 : ℚ) < N := by
    have : 0 < N := Fintype.card_pos
    exact_mod_cast this
  rw [div_le_div_iff₀ hNpos hq]
  have : (S.card : ℚ) * q ≤ Q * N := by exact_mod_cast hcard
  linarith

end SchnorrGrp