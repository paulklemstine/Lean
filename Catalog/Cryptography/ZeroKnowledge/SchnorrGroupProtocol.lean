/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Schnorr identification Σ-protocol in a genuine cyclic group

The catalog already contains an *additive* model of Schnorr (`Cryptography.SchnorrIdentification`
and the files in `Cryptography/ZeroKnowledge/`), where the "group" is the field `ZMod p`,
"scalar multiplication" is field multiplication and the public key of `x` is `x * g`.  That
model is algebraically convenient but it hides the actual group-theoretic content of the
protocol: in the real scheme the prover works in a cyclic group `G` of prime order `q`, the
commitment is `g ^ r`, the public key is `g ^ x`, and verification reads `g ^ z = a * pub ^ c`
with the exponents living in `ZMod q` while the group operation lives in `G`.

This file develops that faithful multiplicative model:

* `gexp h e = h ^ e.val` is exponentiation of a group element by a `ZMod q` scalar; it is
  well defined as a homomorphism precisely on the `q`-torsion (`h ^ q = 1`), which is the
  standing hypothesis throughout.
* `SchnorrGrp.Accepts g pub T` is the verification equation `g ^ z = a * pub ^ c`.

## Main results

* `gexp_add`, `gexp_mul`, `gexp_sub`, `gexp_injective` — the exponentiation API.
* `completeness` — the honest prover `(g ^ r, c, r + c * x)` is always accepted.
* `special_soundness_witness` — two accepting transcripts sharing a commitment with distinct
  challenges yield a genuine discrete logarithm of an *arbitrary* public key `pub`
  (only `pub ^ q = 1` is needed), i.e. knowledge soundness with extractor
  `(z₁ - z₂) * (c₁ - c₂)⁻¹`.
* `special_soundness_eq_witness` — specialised to `pub = g ^ x`, the extractor returns `x`.
* `simulate_accepts`, `honest_eq_simulate`, `hvzk_equiv`, `hvzk_pmf` — perfect
  honest-verifier zero knowledge: the simulator's output is accepting, matches the honest
  transcript under an explicit bijection of the randomness, and induces *literally the same
  distribution* as the honest prover (equality of `PMF`s).
* `accepting_challenges_card_le_one`, `soundness_error_le` — the quantitative soundness
  error: a commitment/response pair fixed in advance is accepted for at most one challenge,
  so a cheating prover succeeds with probability at most `1 / q`.
-/

namespace SchnorrGrp

variable {G : Type*} [CommGroup G] {q : ℕ}

/-! ### Exponentiation by a `ZMod q` scalar -/

/-- Exponentiation of a group element by a scalar in `ZMod q`, via the canonical
representative.  It is a homomorphism in the exponent exactly on `q`-torsion elements. -/
def gexp (h : G) (e : ZMod q) : G := h ^ e.val

/-- On a `q`-torsion element, `h ^ ·` only depends on the exponent modulo `q`. -/
theorem pow_congr_of_modEq {h : G} (hh : h ^ q = 1) {m n : ℕ} (hmn : m ≡ n [MOD q]) :
    h ^ m = h ^ n :=
  pow_eq_pow_iff_modEq.mpr (hmn.of_dvd (orderOf_dvd_iff_pow_eq_one.mpr hh))

@[simp] theorem gexp_zero (h : G) [NeZero q] : gexp h (0 : ZMod q) = 1 := by
  simp [gexp]

theorem gexp_natCast [NeZero q] {h : G} (hh : h ^ q = 1) (n : ℕ) :
    gexp h ((n : ZMod q)) = h ^ n :=
  pow_congr_of_modEq hh (by rw [ZMod.val_natCast]; exact Nat.mod_modEq n q)

theorem gexp_add [NeZero q] {h : G} (hh : h ^ q = 1) (e₁ e₂ : ZMod q) :
    gexp h (e₁ + e₂) = gexp h e₁ * gexp h e₂ := by
  rw [gexp, gexp, gexp, ← pow_add]
  exact pow_congr_of_modEq hh (by rw [ZMod.val_add]; exact Nat.mod_modEq _ q)

theorem gexp_pow_q [NeZero q] {h : G} (hh : h ^ q = 1) (e : ZMod q) : (gexp h e) ^ q = 1 := by
  rw [gexp, ← pow_mul, mul_comm, pow_mul, hh, one_pow]

theorem gexp_mul [NeZero q] {h : G} (hh : h ^ q = 1) (e₁ e₂ : ZMod q) :
    gexp h (e₁ * e₂) = gexp (gexp h e₁) e₂ := by
  rw [gexp, gexp, gexp, ← pow_mul]
  exact pow_congr_of_modEq hh (by rw [ZMod.val_mul]; exact Nat.mod_modEq _ q)

theorem gexp_neg [NeZero q] {h : G} (hh : h ^ q = 1) (e : ZMod q) :
    gexp h (-e) = (gexp h e)⁻¹ := by
  rw [eq_inv_iff_mul_eq_one, ← gexp_add hh, neg_add_cancel, gexp_zero]

theorem gexp_sub [NeZero q] {h : G} (hh : h ^ q = 1) (e₁ e₂ : ZMod q) :
    gexp h (e₁ - e₂) = gexp h e₁ * (gexp h e₂)⁻¹ := by
  rw [sub_eq_add_neg, gexp_add hh, gexp_neg hh]

theorem gexp_one [Fact (1 < q)] (h : G) : gexp h (1 : ZMod q) = h := by
  simp [gexp, ZMod.val_one]

/-- For a generator of order exactly `q`, `gexp g` kills only the zero exponent. -/
theorem gexp_eq_one_iff [NeZero q] {g : G} (hg : orderOf g = q) (e : ZMod q) :
    gexp g e = 1 ↔ e = 0 := by
  refine ⟨fun h => ?_, by rintro rfl; simp⟩
  have hd : orderOf g ∣ e.val := orderOf_dvd_iff_pow_eq_one.mpr h
  rw [hg] at hd
  exact (ZMod.val_eq_zero e).mp (Nat.eq_zero_of_dvd_of_lt hd (ZMod.val_lt e))

/-- For a generator of order exactly `q`, exponentiation is injective in the exponent:
discrete logarithms are unique. -/
theorem gexp_injective [NeZero q] {g : G} (hg : orderOf g = q) :
    Function.Injective (gexp g : ZMod q → G) := by
  have hgq : g ^ q = 1 := by rw [← hg]; exact pow_orderOf_eq_one g
  intro a b hab
  have h1 : gexp g (a - b) = 1 := by rw [gexp_sub hgq, hab, mul_inv_cancel]
  exact sub_eq_zero.mp ((gexp_eq_one_iff hg _).mp h1)

/-- A nontrivial element of a group of exponent `q`, `q` prime, has order exactly `q`. -/
theorem orderOf_eq_of_prime [Fact q.Prime] {h : G} (hh : h ^ q = 1) (h1 : h ≠ 1) :
    orderOf h = q :=
  ((Nat.Prime.eq_one_or_self_of_dvd Fact.out _ (orderOf_dvd_iff_pow_eq_one.mpr hh)).resolve_left
    (fun ho => h1 (orderOf_eq_one_iff.mp ho)))

/-! ### The protocol -/

/-- A protocol transcript in the group model: commitment `a ∈ G`, challenge `c` and
response `z` in `ZMod q`. -/
@[ext]
structure Transcript (G : Type*) (q : ℕ) where
  /-- The commitment. -/
  a : G
  /-- The challenge. -/
  c : ZMod q
  /-- The response. -/
  z : ZMod q

/-- The Schnorr verifier: accept `(a, c, z)` for public key `pub` iff `g ^ z = a * pub ^ c`. -/
def Accepts (g pub : G) (T : Transcript G q) : Prop :=
  gexp g T.z = T.a * gexp pub T.c

/-- The honest prover's transcript with randomness `r` on challenge `c`. -/
def honest (g : G) (x r c : ZMod q) : Transcript G q := ⟨gexp g r, c, r + c * x⟩

/-- The honest-verifier simulator: choose the response `z` at random and back-solve the
commitment as `g ^ z * (pub ^ c)⁻¹`.  It uses no witness. -/
def simulate (g pub : G) (c z : ZMod q) : Transcript G q :=
  ⟨gexp g z * (gexp pub c)⁻¹, c, z⟩

/-- **Completeness.** The honest prover holding `x` with public key `g ^ x` is always
accepted, for every randomness `r` and every challenge `c`. -/
theorem completeness [NeZero q] {g : G} (hg : g ^ q = 1) (x r c : ZMod q) :
    Accepts g (gexp g x) (honest g x r c) := by
  show gexp g (r + c * x) = gexp g r * gexp (gexp g x) c
  rw [gexp_add hg, mul_comm c x, gexp_mul hg]

/-- The Schnorr extractor applied to two forking transcripts. -/
def extract (c₁ z₁ c₂ z₂ : ZMod q) : ZMod q := (z₁ - z₂) * (c₁ - c₂)⁻¹

/-- **Knowledge soundness / special soundness.** Two accepting transcripts sharing the
commitment `a` and having distinct challenges produce, via `extract`, a genuine discrete
logarithm of the public key — no secret is assumed to exist beforehand. -/
theorem special_soundness_witness [Fact q.Prime] {g pub : G} (hg : g ^ q = 1)
    (hpub : pub ^ q = 1) (a : G) (c₁ z₁ c₂ z₂ : ZMod q)
    (h₁ : Accepts g pub ⟨a, c₁, z₁⟩) (h₂ : Accepts g pub ⟨a, c₂, z₂⟩) (hc : c₁ ≠ c₂) :
    gexp g (extract c₁ z₁ c₂ z₂) = pub := by
  haveI : Fact (1 < q) := ⟨(Fact.out : q.Prime).one_lt⟩
  simp only [Accepts] at h₁ h₂
  have key : gexp g (z₁ - z₂) = gexp pub (c₁ - c₂) := by
    rw [gexp_sub hg, gexp_sub hpub, h₁, h₂, mul_inv,
      show a * gexp pub c₁ * (a⁻¹ * (gexp pub c₂)⁻¹)
        = (a * a⁻¹) * (gexp pub c₁ * (gexp pub c₂)⁻¹) by ac_rfl]
    simp
  have hne : c₁ - c₂ ≠ 0 := sub_ne_zero.mpr hc
  rw [extract, gexp_mul hg, key, ← gexp_mul hpub, mul_inv_cancel₀ hne, gexp_one]

/-- Existence form of knowledge soundness: a fork proves the public key has a discrete
logarithm base `g`. -/
theorem knowledge_soundness [Fact q.Prime] {g pub : G} (hg : g ^ q = 1) (hpub : pub ^ q = 1)
    (a : G) (c₁ z₁ c₂ z₂ : ZMod q)
    (h₁ : Accepts g pub ⟨a, c₁, z₁⟩) (h₂ : Accepts g pub ⟨a, c₂, z₂⟩) (hc : c₁ ≠ c₂) :
    ∃ x : ZMod q, gexp g x = pub :=
  ⟨extract c₁ z₁ c₂ z₂, special_soundness_witness hg hpub a c₁ z₁ c₂ z₂ h₁ h₂ hc⟩

/-- With `pub = g ^ x` the extractor returns exactly the secret `x`. -/
theorem special_soundness_eq_witness [Fact q.Prime] {g : G} (hg : g ^ q = 1)
    (horder : orderOf g = q) (x : ZMod q) (a : G) (c₁ z₁ c₂ z₂ : ZMod q)
    (h₁ : Accepts g (gexp g x) ⟨a, c₁, z₁⟩) (h₂ : Accepts g (gexp g x) ⟨a, c₂, z₂⟩)
    (hc : c₁ ≠ c₂) :
    extract c₁ z₁ c₂ z₂ = x :=
  gexp_injective horder
    (special_soundness_witness hg (gexp_pow_q hg x) a c₁ z₁ c₂ z₂ h₁ h₂ hc)

/-! ### Honest-verifier zero knowledge -/

/-- The simulator always produces accepting transcripts. -/
theorem simulate_accepts (g pub : G) (c z : ZMod q) :
    Accepts g pub (simulate g pub c z) := by
  show gexp g z = gexp g z * (gexp pub c)⁻¹ * gexp pub c
  group

/-- The honest transcript on randomness `r` is *identical* to the simulated transcript on
response `r + c * x`. -/
theorem honest_eq_simulate [NeZero q] {g : G} (hg : g ^ q = 1) (x r c : ZMod q) :
    honest g x r c = simulate g (gexp g x) c (r + c * x) := by
  have h : gexp g (r + c * x) * (gexp (gexp g x) c)⁻¹ = gexp g r := by
    rw [gexp_add hg, mul_comm c x, gexp_mul hg]
    group
  simp [honest, simulate, h]

/-- The randomness-to-response bijection `r ↦ r + c * x` underlying perfect HVZK. -/
def hvzkEquiv (x c : ZMod q) : ZMod q ≃ ZMod q where
  toFun r := r + c * x
  invFun z := z - c * x
  left_inv := by intro r; simp
  right_inv := by intro z; simp

/-- **Perfect HVZK, bijection form.** Honest and simulated transcripts are matched by the
explicit bijection `hvzkEquiv` of the randomness. -/
theorem hvzk_equiv [NeZero q] {g : G} (hg : g ^ q = 1) (x c r : ZMod q) :
    honest g x r c = simulate g (gexp g x) c (hvzkEquiv x c r) :=
  honest_eq_simulate hg x r c

/-- Pushing the uniform distribution forward along a bijection returns the uniform
distribution. -/
theorem map_uniformOfFintype_equiv {α : Type*} [Fintype α] [Nonempty α] (e : α ≃ α) :
    (PMF.uniformOfFintype α).map e = PMF.uniformOfFintype α := by
  ext a
  simp only [PMF.map_apply, PMF.uniformOfFintype_apply, tsum_fintype]
  rw [Finset.sum_eq_single (e.symm a)
    (by intro b _ hb; simp only [ite_eq_right_iff]; intro h; exact absurd (by rw [h]; simp) hb)
    (by simp)]
  simp

/-- **Perfect HVZK, distributional form.** For each fixed challenge `c`, the distribution of
the honest transcript over uniform randomness `r` is *equal* (not merely close) to the
distribution of the witness-free simulator over a uniform response `z`. -/
theorem hvzk_pmf [NeZero q] {g : G} (hg : g ^ q = 1) (x c : ZMod q) :
    (PMF.uniformOfFintype (ZMod q)).map (fun r => honest g x r c)
      = (PMF.uniformOfFintype (ZMod q)).map (fun z => simulate g (gexp g x) c z) := by
  have h : (fun r => honest g x r c)
      = (fun z => simulate g (gexp g x) c z) ∘ (hvzkEquiv x c) := by
    funext r; exact hvzk_equiv hg x c r
  rw [h, ← PMF.map_comp, map_uniformOfFintype_equiv]

/-! ### Quantitative soundness error -/

open scoped Classical in
/-- A commitment/response pair `(a, z)` fixed *before* the challenge is accepted for at most
one challenge, provided the public key is nontrivial. -/
theorem accepting_challenges_card_le_one [Fact q.Prime] {g pub : G} (hpub : pub ^ q = 1)
    (hpub1 : pub ≠ 1) (a : G) (z : ZMod q) :
    (Finset.univ.filter (fun c : ZMod q => Accepts g pub ⟨a, c, z⟩)).card ≤ 1 := by
  refine Finset.card_le_one.mpr ?_
  intro c₁ h₁ c₂ h₂
  simp only [Finset.mem_filter, Accepts] at h₁ h₂
  have hgg : gexp pub c₁ = gexp pub c₂ :=
    mul_left_cancel (a := a) (by rw [← h₁.2, ← h₂.2])
  exact gexp_injective (orderOf_eq_of_prime hpub hpub1) hgg

open scoped Classical in
/-- **Soundness error `≤ 1/q`.** A prover that must fix `(a, z)` before seeing the uniformly
random challenge is accepted with probability at most `1 / q`. -/
theorem soundness_error_le [Fact q.Prime] {g pub : G} (hpub : pub ^ q = 1) (hpub1 : pub ≠ 1)
    (a : G) (z : ZMod q) :
    ((Finset.univ.filter (fun c : ZMod q => Accepts g pub ⟨a, c, z⟩)).card : ℚ)
        / (Finset.univ : Finset (ZMod q)).card ≤ 1 / q := by
  have hcard : (Finset.univ : Finset (ZMod q)).card = q := by
    simp
  rw [hcard]
  have hq : (0 : ℚ) < q := by
    exact_mod_cast (Fact.out : q.Prime).pos
  have hle : ((Finset.univ.filter (fun c : ZMod q => Accepts g pub ⟨a, c, z⟩)).card : ℚ) ≤ 1 := by
    exact_mod_cast accepting_challenges_card_le_one hpub hpub1 a z
  exact div_le_div_of_nonneg_right hle hq.le

end SchnorrGrp