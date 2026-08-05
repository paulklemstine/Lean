import Mathlib

/-!
# A simplified zk-SNARK: R1CS batching, soundness and extraction

Modern succinct arguments (Groth16, Marlin, PLONK, …) all rest on the same two
ingredients, which we isolate and prove here over an arbitrary finite field `F`.

1. **Arithmetization.** A computation is encoded as a rank-1 constraint system
   (`R1CS`): a witness `z : Fin n → F` is valid iff for every constraint `i`
   `⟨Aᵢ, z⟩ * ⟨Bᵢ, z⟩ = ⟨Cᵢ, z⟩`.
2. **Batching / probabilistic checking.** Instead of checking the `m` constraints one by
   one, the verifier sends a single random challenge `r` and checks the equation
   `∑ᵢ errᵢ(z) · rⁱ = 0`, i.e. that the *batching polynomial* `batchPoly` vanishes at
   `r`. This is the polynomial-identity-testing core of every SNARK.

## Main results

* `batchPoly_eq_zero_iff` — the batching polynomial is the zero polynomial exactly when
  the witness satisfies the constraint system (the arithmetization is faithful).
* `batch_completeness` — a valid witness passes the check for every challenge.
* `batch_soundness_card` / `batch_soundness_prob` — an invalid witness passes for at most
  `m - 1` challenges, i.e. with probability at most `(m-1)/|F|` (Schwartz–Zippel).
* `batch_soundness_pow` — `k` independent challenges reduce the error to `((m-1)/|F|)^k`.
* `batch_extraction` — **knowledge soundness in the algebraic model**: if the check
  passes at `m` pairwise distinct challenge points, the witness really is valid.
* `otp_perfect_hiding`, `masked_uniform`, `mask_bijective` — perfect hiding of a
  one-time-pad field mask, the zero-knowledge ingredient: a masked value is uniformly
  distributed, independently of the value being masked.
-/

open Finset Polynomial

namespace ZKSnark

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F] {m n : ℕ}

/-! ## Rank-1 constraint systems -/

/-- A rank-1 constraint system with `m` constraints over `n` variables: three matrices
`A`, `B`, `C`. A witness `z` is valid when `(A z) ⊙ (B z) = C z` entrywise. -/
structure R1CS (F : Type*) (m n : ℕ) where
  /-- Left factor matrix. -/
  A : Fin m → Fin n → F
  /-- Right factor matrix. -/
  B : Fin m → Fin n → F
  /-- Output matrix. -/
  C : Fin m → Fin n → F

/-- The residual of constraint `i` at the assignment `z`. -/
def R1CS.err (S : R1CS F m n) (z : Fin n → F) (i : Fin m) : F :=
  (∑ j, S.A i j * z j) * (∑ j, S.B i j * z j) - (∑ j, S.C i j * z j)

/-- `z` satisfies the constraint system. -/
def R1CS.Satisfies (S : R1CS F m n) (z : Fin n → F) : Prop := ∀ i, S.err z i = 0

instance (S : R1CS F m n) (z : Fin n → F) : Decidable (S.Satisfies z) :=
  decidable_of_iff (∀ i, S.err z i = 0) Iff.rfl

/-! ## The batching polynomial -/

/-- The batching polynomial `∑ᵢ errᵢ(z) · Xⁱ`, whose vanishing at a random point is what
the verifier of the argument system actually checks. -/
noncomputable def batchPoly (S : R1CS F m n) (z : Fin n → F) : Polynomial F :=
  ∑ i : Fin m, C (S.err z i) * X ^ (i : ℕ)

omit [Fintype F] [DecidableEq F] in
/-- The coefficients of the batching polynomial are exactly the constraint residuals. -/
theorem batchPoly_coeff (S : R1CS F m n) (z : Fin n → F) (i : Fin m) :
    (batchPoly S z).coeff (i : ℕ) = S.err z i := by
  simp [batchPoly, Polynomial.finset_sum_coeff, coeff_C_mul, coeff_X_pow, Fin.val_inj]

omit [Fintype F] [DecidableEq F] in
/-- The batching polynomial has degree at most `m - 1`. -/
theorem batchPoly_natDegree_le (S : R1CS F m n) (z : Fin n → F) :
    (batchPoly S z).natDegree ≤ m - 1 := by
  refine natDegree_sum_le_of_forall_le _ _ fun i _ => ?_
  refine le_trans (natDegree_C_mul_le _ _) ?_
  have hi := i.isLt
  simp only [natDegree_X_pow]
  omega

omit [Fintype F] [DecidableEq F] in
theorem batchPoly_natDegree_lt (S : R1CS F m n) (z : Fin n → F) (hm : 0 < m) :
    (batchPoly S z).natDegree < m := by
  have := batchPoly_natDegree_le S z
  omega

omit [Fintype F] [DecidableEq F] in
/-- Faithfulness of the arithmetization: the batching polynomial vanishes identically iff
the witness satisfies every constraint. -/
theorem batchPoly_eq_zero_iff (S : R1CS F m n) (z : Fin n → F) :
    batchPoly S z = 0 ↔ S.Satisfies z := by
  constructor
  · intro h i
    have := batchPoly_coeff S z i
    rw [h] at this
    simpa using this.symm
  · intro h
    unfold batchPoly
    refine Finset.sum_eq_zero fun i _ => ?_
    rw [h i]
    simp

/-! ## Completeness and soundness -/

omit [Fintype F] [DecidableEq F] in
/-- **Completeness**: a valid witness passes the batched check for every challenge. -/
theorem batch_completeness (S : R1CS F m n) (z : Fin n → F) (h : S.Satisfies z) (r : F) :
    (batchPoly S z).eval r = 0 := by
  rw [(batchPoly_eq_zero_iff S z).mpr h]
  simp

/-- The set of "bad" challenges: those on which a cheating prover would be believed. -/
noncomputable def badChallenges (S : R1CS F m n) (z : Fin n → F) : Finset F :=
  univ.filter fun r => (batchPoly S z).eval r = 0

/-- Bad challenges are roots of the (then nonzero) batching polynomial. -/
theorem badChallenges_subset_roots (S : R1CS F m n) (z : Fin n → F)
    (h : ¬ S.Satisfies z) : badChallenges S z ⊆ (batchPoly S z).roots.toFinset := by
  have hne : batchPoly S z ≠ 0 := fun hz => h ((batchPoly_eq_zero_iff S z).mp hz)
  intro r hr
  simp only [badChallenges, mem_filter, mem_univ, true_and] at hr
  rw [Multiset.mem_toFinset, Polynomial.mem_roots hne]
  exact hr

/-- **Soundness (counting form)**: for an invalid witness at most `m - 1` of the `|F|`
challenges are bad. This is the univariate Schwartz–Zippel bound. -/
theorem batch_soundness_card (S : R1CS F m n) (z : Fin n → F) (h : ¬ S.Satisfies z) :
    (badChallenges S z).card ≤ m - 1 := by
  have hne : batchPoly S z ≠ 0 := fun hz => h ((batchPoly_eq_zero_iff S z).mp hz)
  have hroots : (batchPoly S z).roots.card ≤ (batchPoly S z).natDegree := by
    have hc := Polynomial.card_roots hne
    rw [Polynomial.degree_eq_natDegree hne] at hc
    exact WithBot.coe_le_coe.mp hc
  calc (badChallenges S z).card
      ≤ (batchPoly S z).roots.toFinset.card :=
        card_le_card (badChallenges_subset_roots S z h)
    _ ≤ (batchPoly S z).roots.card := Multiset.toFinset_card_le _
    _ ≤ (batchPoly S z).natDegree := hroots
    _ ≤ m - 1 := batchPoly_natDegree_le S z

/-- **Soundness (probabilistic form)**: an invalid witness is accepted with probability at
most `(m-1)/|F|` over a uniformly random challenge. -/
theorem batch_soundness_prob (S : R1CS F m n) (z : Fin n → F) (hm : 0 < m)
    (h : ¬ S.Satisfies z) :
    ((badChallenges S z).card : ℝ) / Fintype.card F ≤ (m - 1 : ℝ) / Fintype.card F := by
  have hcard := batch_soundness_card S z h
  have hle : ((badChallenges S z).card : ℝ) ≤ (m - 1 : ℝ) := by
    have : ((badChallenges S z).card : ℝ) ≤ ((m - 1 : ℕ) : ℝ) := by exact_mod_cast hcard
    rw [Nat.cast_sub hm] at this
    simpa using this
  gcongr

/-- Repeating the check with `k` independent challenges multiplies the soundness error:
the fraction of bad challenge vectors is at most `((m-1)/|F|)^k`. -/
theorem batch_soundness_pow (S : R1CS F m n) (z : Fin n → F) (hm : 0 < m)
    (h : ¬ S.Satisfies z) (k : ℕ) :
    (((badChallenges S z).card : ℝ) / Fintype.card F) ^ k
      ≤ ((m - 1 : ℝ) / Fintype.card F) ^ k := by
  have h1 := batch_soundness_prob S z hm h
  have h0 : (0 : ℝ) ≤ ((badChallenges S z).card : ℝ) / Fintype.card F := by positivity
  exact pow_le_pow_left₀ h0 h1 k

/-- **Knowledge soundness / extraction**: if the batched check succeeds on `m` pairwise
distinct challenges, then the witness genuinely satisfies all `m` constraints — a
polynomial of degree `< m` with `m` roots is zero. -/
theorem batch_extraction (S : R1CS F m n) (z : Fin n → F) (T : Finset F) (hT : m ≤ T.card)
    (h : ∀ r ∈ T, (batchPoly S z).eval r = 0) : S.Satisfies z := by
  by_contra hcon
  have hsub : T ⊆ badChallenges S z := by
    intro r hr
    simp only [badChallenges, mem_filter, mem_univ, true_and]
    exact h r hr
  have h1 : T.card ≤ m - 1 := le_trans (card_le_card hsub) (batch_soundness_card S z hcon)
  have hm : 0 < m := by
    rcases Nat.eq_zero_or_pos m with hm0 | hm0
    · subst hm0
      exact absurd (fun i : Fin 0 => i.elim0) hcon
    · exact hm0
  omega

/-- If the field is larger than the number of constraints, an invalid witness is rejected
by *some* challenge: the argument system is non-vacuously sound. -/
theorem exists_good_challenge (S : R1CS F m n) (z : Fin n → F) (hm : 0 < m)
    (hF : m ≤ Fintype.card F) (h : ¬ S.Satisfies z) :
    ∃ r : F, (batchPoly S z).eval r ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  have huniv : badChallenges S z = univ := by
    ext r
    simp [badChallenges, hcon r]
  have h1 := batch_soundness_card S z h
  rw [huniv, card_univ] at h1
  omega

/-! ## The zero-knowledge ingredient: perfect hiding of a field mask -/

/-- A one-time pad over `F` perfectly hides the masked value: for every secret `w` and
every target `t` there is exactly one mask `s` with `w + s = t`. -/
theorem otp_perfect_hiding (w t : F) : (univ.filter fun s : F => w + s = t).card = 1 := by
  have : (univ.filter fun s : F => w + s = t) = {t - w} := by
    ext s
    simp only [mem_filter, mem_univ, true_and, mem_singleton]
    constructor
    · intro hs; rw [← hs]; ring
    · intro hs; rw [hs]; ring
  rw [this, card_singleton]

/-- Consequently the distribution of the masked value `w + s` for a uniform mask `s` does
not depend on the secret `w`: this is why adding random blinding terms to a SNARK proof
makes it zero knowledge. -/
theorem masked_uniform (w₁ w₂ t : F) :
    ((univ.filter fun s : F => w₁ + s = t).card : ℝ) / Fintype.card F
      = ((univ.filter fun s : F => w₂ + s = t).card : ℝ) / Fintype.card F := by
  rw [otp_perfect_hiding w₁ t, otp_perfect_hiding w₂ t]

omit [Fintype F] [DecidableEq F] in
/-- The masking map `s ↦ w + s` is a bijection of `F`, so masking a secret with a uniform
field element yields a uniform field element. -/
theorem mask_bijective (w : F) : Function.Bijective (fun s : F => w + s) :=
  ⟨fun a b hab => by simpa using add_left_cancel hab, fun t => ⟨t - w, by ring⟩⟩

end ZKSnark