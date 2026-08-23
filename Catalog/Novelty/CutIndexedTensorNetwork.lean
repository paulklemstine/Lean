import Novelty.CutIndexedEntropy
import Novelty.IITTensorNetworkMPS

/-!
# Cut-indexed defects III: the quantum code state and its cut entropies

Files I and II developed the *classical* cut data of a codebook: the bond
dimension `cutRank C S` across a cut, the cut-wise Singleton inequality, and the
Shannon entropy `cutEntropy C S` of the induced marginal.  This file promotes the
codebook to a **quantum state** — the uniform superposition
`|C⟩ = |C|^(-1/2) ∑_{c ∈ C} |c⟩` — presented, for each cut `S`, as the coefficient
matrix `codeState C S` of a bipartite pure state in the sense of
`Catalog/Novelty/IITTensorNetworkSchmidt.lean`.

The point of the exercise is that the *tensor-network* cut data of `|C⟩` (Schmidt
rank, bond dimension, entanglement entropy) is controlled by, and for MDS codes
computed exactly by, the *combinatorial* cut data of `C`.

## Main results

* `normalized_codeState` : `|C⟩` is a unit vector, for every cut;
* `hasBondDim_codeState` : the code state factors through a virtual space of
  dimension `cutRank C S`, i.e. it is an MPS bond of that size;
* `schmidtRank_codeState_le` : hence `Schmidt rank ≤ cutRank C S`;
* `schmidtRank_codeState_le_pow_compl` : the complementary (purity) bound
  `Schmidt rank ≤ q ^ |Sᶜ|`;
* `entanglementEntropy_codeState_le_min` : **quantum cut-wise Singleton.**  For a
  code of minimum distance `d`, the entanglement entropy of `|C⟩` across any cut
  obeys `E(S) ≤ min (|S|, n + 1 - d) * log q`, the same plateau curve that bounds
  the classical cut entropy;
* `rhoLeft_codeState_of_isMDS` : for an MDS code and a cut of size at most
  `min (k, d - 1)`, the reduced density matrix is *exactly* maximally mixed;
* `entanglementEntropy_codeState_of_isMDS` : consequently
  `E(S) = |S| * log q` — **the quantum cut-wise Singleton inequality is saturated
  by MDS code states in the whole regime `|S| ≤ min (k, d-1)`**;
* `schmidtRank_codeState_of_isMDS` : the Schmidt rank across such a cut is exactly
  `q ^ |S|`, i.e. the bond-dimension bound `schmidtRank ≤ cutRank` is attained;
* `entanglementEntropy_codeState_eq_log_schmidtRank` : the entropy–Schmidt-rank
  bound of `IITTensorNetworkSchmidt.lean` is *saturated* by MDS code states;
* `mutualInformation_codeState_of_isMDS` : the quantum mutual information across
  such a cut lies between `|S| log q` and `2 |S| log q`, the extreme values allowed
  by `IITTensorNetwork.mutualInformation_le_two_log_schmidtRank`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the classical cut-wise Singleton inequality should have
a verbatim quantum avatar for the uniform code state, and MDS codes should be
exactly the states that saturate it — a discrete analogue of "maximal entanglement
up to the RT surface".

Experiment (Experimenter): the bound direction is cheap once the code state is
factored through the set of realised patterns
(`hasBondDim_codeState`, via `Finset.equivFin` on the image), because Schmidt rank
is then bounded by `cutRank C S`, which files I–II already bound by
`min (|S|, k)` in the exponent.  The saturation direction required computing
`ρ_A = M Mᴴ` entrywise: off-diagonal entries `(a, a')` count codewords that agree
off `S`, and minimum distance kills them as soon as `|S| ≤ d - 1`; the diagonal
entries are the balanced fibre counts of `fiber_card_of_isMDS`.  The result is
`ρ_A = q^(-|S|) • 1`, whose von Neumann entropy is `|S| log q` by
`IITTensorNetwork.vnEntropy_smul_one`.

Analysis (Analyst): the two saturation regimes differ, and this is not an artefact:
classically the entropy plateau reaches `k log q`, quantum-mechanically the purity
of `|C⟩` forces `E(S) = E(Sᶜ) ≤ min(|S|, |Sᶜ|) log q`, so exact saturation can only
be expected for `|S| ≤ d - 1` (where the complement still resolves the code).  The
theorem is stated with exactly that guard, and the counterexample that motivates
it (the even-weight code `n = 3, q = 2, d = 2` at `|S| = 2 = k > d - 1`) is
recorded in `ComputationalEvidence.md`.

Experiment (Experimenter, failed run): the natural next step — "both marginals of a
pure state have equal entropy, hence `I(A:B) = 2 |S| log q`" — could *not* be
carried out with `Matrix.charpoly_mul_comm`, which is stated for square matrices
only, whereas the code-state coefficient matrix is genuinely rectangular
(`q ^ |S|` by `q ^ (n - |S|)`).  Rather than assume the rectangular statement, the
mutual-information result is recorded as the two-sided sandwich that the available
machinery actually proves; closing the gap is Direction 3 of
`FUTURE_DIRECTIONS.md`.

Critique (Critic): `entanglementEntropy_codeState_of_isMDS` is not vacuous — the
regime `|S| ≤ min(k, d-1)` is nonempty for every MDS code with `d ≥ 2` and
`k ≥ 1`, and `CutIndexedExamples.lean` exhibits a concrete instance where the
hypotheses are verified by `decide`.
-/

open Finset Matrix
open scoped ComplexOrder

namespace CutIndexedSingleton

open IITTensorNetwork

variable {n q : ℕ}

/-! ## Gluing the two sides of a cut -/

/-- Reassemble a word from its restrictions to a cut and to its complement. -/
def glue (S : Finset (Fin n)) (a : {i // i ∈ S} → Fin q) (b : {i // i ∈ Sᶜ} → Fin q) :
    Word n q :=
  fun i => if h : i ∈ S then a ⟨i, h⟩ else b ⟨i, Finset.mem_compl.mpr h⟩

@[simp] lemma proj_glue_self (S : Finset (Fin n)) (a : {i // i ∈ S} → Fin q)
    (b : {i // i ∈ Sᶜ} → Fin q) : proj S (glue S a b) = a := by
  funext i
  simp [proj, glue, i.2]

@[simp] lemma proj_compl_glue (S : Finset (Fin n)) (a : {i // i ∈ S} → Fin q)
    (b : {i // i ∈ Sᶜ} → Fin q) : proj Sᶜ (glue S a b) = b := by
  funext i
  have hi : (i : Fin n) ∉ S := Finset.mem_compl.mp i.2
  simp [proj, glue, hi]

@[simp] lemma glue_proj (S : Finset (Fin n)) (c : Word n q) :
    glue S (proj S c) (proj Sᶜ c) = c := by
  funext i
  by_cases h : i ∈ S <;> simp [glue, proj, h]

lemma glue_injective (S : Finset (Fin n)) {a a' : {i // i ∈ S} → Fin q}
    {b b' : {i // i ∈ Sᶜ} → Fin q} (h : glue S a b = glue S a' b') : a = a' ∧ b = b' := by
  constructor
  · rw [← proj_glue_self S a b, ← proj_glue_self S a' b', h]
  · rw [← proj_compl_glue S a b, ← proj_compl_glue S a' b', h]

/-- The pairs of half-patterns that glue to a codeword biject with the code. -/
lemma card_gluePairs (C : Finset (Word n q)) (S : Finset (Fin n)) :
    ((Finset.univ : Finset ((({i // i ∈ S} → Fin q)) × (({i // i ∈ Sᶜ} → Fin q)))).filter
      (fun p => glue S p.1 p.2 ∈ C)).card = C.card := by
  classical
  refine Finset.card_bij' (fun p _ => glue S p.1 p.2) (fun c _ => (proj S c, proj Sᶜ c))
    ?_ ?_ ?_ ?_
  · intro p hp
    exact (Finset.mem_filter.mp hp).2
  · intro c hc
    refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
    rwa [glue_proj]
  · intro p _
    obtain ⟨a, b⟩ := p
    simp
  · intro c _
    exact glue_proj S c

/-! ## The uniform code state -/

/-- The coefficient matrix, across the cut `S`, of the uniform superposition over
the codebook `C`. -/
noncomputable def codeState (C : Finset (Word n q)) (S : Finset (Fin n)) :
    Matrix ({i // i ∈ S} → Fin q) ({i // i ∈ Sᶜ} → Fin q) ℂ :=
  Matrix.of fun a b => if glue S a b ∈ C then (((Real.sqrt C.card)⁻¹ : ℝ) : ℂ) else 0

lemma amp_sq {C : Finset (Word n q)} (hC : C.Nonempty) :
    ((Real.sqrt C.card)⁻¹ : ℝ) ^ 2 = ((C.card : ℝ))⁻¹ := by
  have hpos : (0 : ℝ) < C.card := by exact_mod_cast Finset.card_pos.mpr hC
  rw [inv_pow, Real.sq_sqrt hpos.le]

lemma norm_codeState_sq (C : Finset (Word n q)) (S : Finset (Fin n))
    (a : {i // i ∈ S} → Fin q) (b : {i // i ∈ Sᶜ} → Fin q) :
    ‖codeState C S a b‖ ^ 2 =
      if glue S a b ∈ C then (((Real.sqrt C.card)⁻¹ : ℝ)) ^ 2 else 0 := by
  by_cases h : glue S a b ∈ C
  · simp only [codeState, Matrix.of_apply, if_pos h, Complex.norm_real, Real.norm_eq_abs]
    rw [sq_abs]
  · simp [codeState, h]

/-- **The uniform code state is a unit vector across every cut.** -/
theorem normalized_codeState {C : Finset (Word n q)} (hC : C.Nonempty) (S : Finset (Fin n)) :
    Normalized (codeState C S) := by
  classical
  have hpos : (0 : ℝ) < C.card := by exact_mod_cast Finset.card_pos.mpr hC
  unfold Normalized
  have hstep : ∀ a : {i // i ∈ S} → Fin q, ∀ b : {i // i ∈ Sᶜ} → Fin q,
      ‖codeState C S a b‖ ^ 2 =
        if glue S a b ∈ C then (((Real.sqrt C.card)⁻¹ : ℝ)) ^ 2 else 0 :=
    fun a b => norm_codeState_sq C S a b
  calc ∑ a, ∑ b, ‖codeState C S a b‖ ^ 2
      = ∑ a, ∑ b, (if glue S a b ∈ C then (((Real.sqrt C.card)⁻¹ : ℝ)) ^ 2 else 0) := by
        exact Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => hstep a b
    _ = ∑ p : (({i // i ∈ S} → Fin q)) × (({i // i ∈ Sᶜ} → Fin q)),
          (if glue S p.1 p.2 ∈ C then (((Real.sqrt C.card)⁻¹ : ℝ)) ^ 2 else 0) := by
        rw [Fintype.sum_prod_type]
    _ = ∑ _p ∈ (Finset.univ.filter fun p : (({i // i ∈ S} → Fin q)) × (({i // i ∈ Sᶜ} → Fin q))
          => glue S p.1 p.2 ∈ C), (((Real.sqrt C.card)⁻¹ : ℝ)) ^ 2 := by
        rw [Finset.sum_filter]
    _ = (C.card : ℝ) * (((Real.sqrt C.card)⁻¹ : ℝ)) ^ 2 := by
        rw [Finset.sum_const, card_gluePairs, nsmul_eq_mul]
    _ = 1 := by
        rw [amp_sq hC]
        field_simp

/-! ## Bond dimension of the code state -/

/-- **The code state is an MPS bond of size `cutRank C S`.**  It factors through
the space of *realised patterns* on the cut. -/
theorem hasBondDim_codeState (C : Finset (Word n q)) (S : Finset (Fin n)) :
    HasBondDim (codeState C S) (cutRank C S) := by
  classical
  set r := cutRank C S with hr
  let e : {y // y ∈ C.image (proj S)} ≃ Fin r := (C.image (proj S)).equivFin
  refine ⟨Matrix.of fun a j => if a = ((e.symm j : {y // y ∈ C.image (proj S)}) : _) then 1 else 0,
    Matrix.of fun j b => codeState C S ((e.symm j : {y // y ∈ C.image (proj S)}) : _) b, ?_⟩
  ext a b
  rw [Matrix.mul_apply]
  by_cases ha : a ∈ C.image (proj S)
  · rw [Finset.sum_eq_single (e ⟨a, ha⟩)]
    · simp
    · intro j _ hj
      have : a ≠ ((e.symm j : {y // y ∈ C.image (proj S)}) : _) := by
        intro hcontra
        apply hj
        rw [show (⟨a, ha⟩ : {y // y ∈ C.image (proj S)}) = e.symm j from Subtype.ext hcontra]
        simp
      simp [this]
    · intro hcon
      exact absurd (Finset.mem_univ (e ⟨a, ha⟩)) hcon
  · have hzero : codeState C S a b = 0 := by
      have : glue S a b ∉ C := by
        intro hmem
        exact ha (Finset.mem_image.mpr ⟨glue S a b, hmem, proj_glue_self S a b⟩)
      simp [codeState, this]
    rw [hzero, eq_comm]
    apply Finset.sum_eq_zero
    intro j _
    have : a ≠ ((e.symm j : {y // y ∈ C.image (proj S)}) : _) := by
      intro hcontra
      exact ha (hcontra ▸ (e.symm j).2)
    simp [this]

/-- **Schmidt rank of the code state is at most the classical bond dimension.** -/
theorem schmidtRank_codeState_le (C : Finset (Word n q)) (S : Finset (Fin n)) :
    schmidtRank (codeState C S) ≤ cutRank C S :=
  schmidtRank_le_of_hasBondDim (hasBondDim_codeState C S)

/-- **Quantum cut-wise Singleton inequality.**  The entanglement entropy of the
uniform code state across a cut obeys the same plateau bound
`min (|S|, n + 1 - d) * log q` as the classical cut entropy. -/
theorem entanglementEntropy_codeState_le_min {C : Finset (Word n q)} {d : ℕ}
    (hC : C.Nonempty) (hd : MinDist C d) (hd1 : 1 ≤ d) (S : Finset (Fin n)) :
    entanglementEntropy (codeState C S) ≤ (min S.card (CutData.sdim n d) : ℕ) * Real.log q := by
  classical
  have hnorm := normalized_codeState hC S
  have h1 := entanglementEntropy_le_log_schmidtRank hnorm
  have hrk : 1 ≤ schmidtRank (codeState C S) := schmidtRank_pos hnorm
  have h2 : (schmidtRank (codeState C S) : ℝ) ≤ (cutRank C S : ℝ) := by
    exact_mod_cast schmidtRank_codeState_le C S
  have hpos : (0 : ℝ) < schmidtRank (codeState C S) := by exact_mod_cast hrk
  have h3 : Real.log (schmidtRank (codeState C S)) ≤ Real.log (cutRank C S) :=
    Real.log_le_log hpos h2
  have hcut : Real.log (cutRank C S) ≤ (min S.card (CutData.sdim n d) : ℕ) * Real.log q := by
    have hrankpos : (0 : ℝ) < cutRank C S := by
      have : 0 < cutRank C S := by
        rw [cutRank, Finset.card_pos]
        exact hC.image _
      exact_mod_cast this
    rcases le_total S.card (CutData.sdim n d) with h | h
    · rw [Nat.min_eq_left h]
      have hb : (cutRank C S : ℝ) ≤ ((q : ℝ)) ^ S.card := by
        exact_mod_cast (codeCutData C).rank_le_pow S
      have := Real.log_le_log hrankpos hb
      rwa [Real.log_pow] at this
    · rw [Nat.min_eq_right h]
      have hb : (cutRank C S : ℝ) ≤ ((q : ℝ)) ^ (CutData.sdim n d) := by
        have h4 : cutRank C S ≤ C.card := Finset.card_image_le
        have h5 : C.card ≤ q ^ CutData.sdim n d := singleton_bound_of_minDist hd hd1
        exact_mod_cast h4.trans h5
      have := Real.log_le_log hrankpos hb
      rwa [Real.log_pow] at this
  linarith

/-- **Purity bound.**  The Schmidt rank across a cut is also bounded by the local
dimension of the *complementary* side: `q ^ |Sᶜ|`. -/
theorem schmidtRank_codeState_le_pow_compl (C : Finset (Word n q)) (S : Finset (Fin n)) :
    schmidtRank (codeState C S) ≤ q ^ (Sᶜ).card := by
  have h : schmidtRank (codeState C S) ≤ Fintype.card ({i // i ∈ Sᶜ} → Fin q) :=
    Matrix.rank_le_card_width (codeState C S)
  rwa [Fintype.card_fun, Fintype.card_coe, Fintype.card_fin] at h

/-! ## Exact saturation for MDS codes -/

/-- The codewords above a pattern on the cut biject with the completions of that
pattern. -/
lemma card_completions {C : Finset (Word n q)} (S : Finset (Fin n))
    (a : {i // i ∈ S} → Fin q) :
    ((Finset.univ : Finset ({i // i ∈ Sᶜ} → Fin q)).filter
      (fun b => glue S a b ∈ C)).card = (fiber C S a).card := by
  classical
  refine Finset.card_bij' (fun b _ => glue S a b) (fun c _ => proj Sᶜ c) ?_ ?_ ?_ ?_
  · intro b hb
    exact Finset.mem_filter.mpr ⟨(Finset.mem_filter.mp hb).2, by simp⟩
  · intro c hc
    obtain ⟨hcC, hca⟩ := Finset.mem_filter.mp hc
    refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
    have hg : glue S (proj S c) (proj Sᶜ c) = c := glue_proj S c
    rw [hca] at hg
    rwa [hg]
  · intro b _
    simp
  · intro c hc
    obtain ⟨-, hca⟩ := Finset.mem_filter.mp hc
    have hg : glue S (proj S c) (proj Sᶜ c) = c := glue_proj S c
    rw [hca] at hg
    exact hg

/-- **The reduced state of an MDS code state is exactly maximally mixed.**  If the
cut is small enough that its complement still resolves the code
(`|S| ≤ d - 1`) and small enough to sit below the Singleton dimension
(`|S| ≤ k`), the marginal of `|C⟩` on `S` is the maximally mixed state on
`q ^ |S|` levels. -/
theorem rhoLeft_codeState_of_isMDS {C : Finset (Word n q)} {d : ℕ} (hmds : IsMDS C d)
    (hd1 : 1 ≤ d) (hq : 0 < q) {S : Finset (Fin n)} (hSk : S.card ≤ CutData.sdim n d)
    (hSd : S.card < d) :
    rhoLeft (codeState C S) = ((((q ^ S.card : ℕ) : ℝ)⁻¹ : ℝ) : ℂ) • (1 : Matrix _ _ ℂ) := by
  classical
  have hCcard : C.card = q ^ CutData.sdim n d := hmds.2
  have hCne : C.Nonempty := by
    rw [← Finset.card_pos, hCcard]
    exact Nat.pow_pos hq
  have hNpos : (0 : ℝ) < C.card := by exact_mod_cast Finset.card_pos.mpr hCne
  ext a a'
  rw [rhoLeft, Matrix.mul_apply]
  by_cases haa : a = a'
  · subst haa
    -- diagonal: count the completions of `a`, i.e. the fibre of the projection
    have hterm : ∀ b : {i // i ∈ Sᶜ} → Fin q,
        codeState C S a b * (codeState C S)ᴴ b a
          = if glue S a b ∈ C then ((((C.card : ℝ))⁻¹ : ℝ) : ℂ) else 0 := by
      intro b
      by_cases h : glue S a b ∈ C
      · simp only [codeState, Matrix.of_apply, Matrix.conjTranspose_apply, if_pos h,
          RCLike.star_def, Complex.conj_ofReal]
        rw [← Complex.ofReal_mul, ← sq, amp_sq hCne]
      · simp [codeState, Matrix.conjTranspose_apply, h]
    rw [Finset.sum_congr rfl fun b _ => hterm b, ← Finset.sum_filter, Finset.sum_const,
      card_completions S a, nsmul_eq_mul]
    rw [fiber_card_of_isMDS hmds hd1 hSk a, hCcard]
    simp only [Matrix.smul_apply, Matrix.one_apply_eq, smul_eq_mul, mul_one]
    have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
    have hreal : ((q ^ (CutData.sdim n d - S.card) : ℕ) : ℝ)
        * (((q ^ CutData.sdim n d : ℕ) : ℝ))⁻¹ = (((q ^ S.card : ℕ) : ℝ))⁻¹ := by
      push_cast
      field_simp
      rw [← pow_add]
      congr 1
      omega
    have hcast := congrArg (fun x : ℝ => (x : ℂ)) hreal
    push_cast at hcast ⊢
    exact hcast
  · -- off diagonal: two codewords agreeing off `S` are within distance `|S| < d`
    have hterm : ∀ b : {i // i ∈ Sᶜ} → Fin q,
        codeState C S a b * (codeState C S)ᴴ b a' = 0 := by
      intro b
      by_cases h1 : glue S a b ∈ C
      · by_cases h2 : glue S a' b ∈ C
        · exfalso
          have hne : glue S a b ≠ glue S a' b := by
            intro hcon
            exact haa (glue_injective S hcon).1
          have hdist := hmds.1 _ h1 _ h2 hne
          have hproj : proj Sᶜ (glue S a b) = proj Sᶜ (glue S a' b) := by simp
          have hle := hammingDist_le_of_proj_eq hproj
          have hcompl : (Sᶜ).card = n - S.card := by
            rw [Finset.card_compl, Fintype.card_fin]
          rw [hcompl] at hle
          have hSn : S.card ≤ n := Finset.card_le_univ S |>.trans (by simp)
          omega
        · simp [codeState, Matrix.conjTranspose_apply, h2]
      · simp [codeState, Matrix.conjTranspose_apply, h1]
    rw [Finset.sum_congr rfl fun b _ => hterm b, Finset.sum_const_zero]
    simp [Matrix.smul_apply, Matrix.one_apply_ne haa]

/-- **MDS code states saturate the quantum cut-wise Singleton inequality.**  In
the regime `|S| ≤ min (k, d - 1)` the entanglement entropy of `|C⟩` across the cut
is exactly `|S| * log q`. -/
theorem entanglementEntropy_codeState_of_isMDS {C : Finset (Word n q)} {d : ℕ}
    (hmds : IsMDS C d) (hd1 : 1 ≤ d) (hq : 0 < q) {S : Finset (Fin n)}
    (hSk : S.card ≤ CutData.sdim n d) (hSd : S.card < d) :
    entanglementEntropy (codeState C S) = S.card * Real.log q := by
  have hqR : (0 : ℝ) < q := by exact_mod_cast hq
  have hpow : (0 : ℝ) < ((q ^ S.card : ℕ) : ℝ) := by
    have : 0 < q ^ S.card := Nat.pow_pos hq
    exact_mod_cast this
  rw [entanglementEntropy, rhoLeft_codeState_of_isMDS hmds hd1 hq hSk hSd,
    vnEntropy_smul_one]
  have hcard : Fintype.card ({i // i ∈ S} → Fin q) = q ^ S.card := by
    rw [Fintype.card_fun, Fintype.card_coe, Fintype.card_fin]
  rw [hcard]
  have hneg : Real.negMulLog (((q ^ S.card : ℕ) : ℝ))⁻¹
      = (((q ^ S.card : ℕ) : ℝ))⁻¹ * Real.log ((q ^ S.card : ℕ) : ℝ) := by
    simp only [Real.negMulLog_def, Real.log_inv]
    ring
  rw [hneg, ← mul_assoc, mul_inv_cancel₀ hpow.ne', one_mul]
  push_cast
  rw [Real.log_pow]

/-- **The Schmidt rank of an MDS code state is maximal across every small cut.**
In the regime `|S| ≤ min (k, d - 1)` the bond dimension of `|C⟩` is exactly the
full local dimension `q ^ |S|`. -/
theorem schmidtRank_codeState_of_isMDS {C : Finset (Word n q)} {d : ℕ}
    (hmds : IsMDS C d) (hd1 : 1 ≤ d) (hq : 0 < q) {S : Finset (Fin n)}
    (hSk : S.card ≤ CutData.sdim n d) (hSd : S.card < d) :
    schmidtRank (codeState C S) = q ^ S.card := by
  classical
  have hpos : (0 : ℝ) < ((q ^ S.card : ℕ) : ℝ) := by
    have hp : 0 < q ^ S.card := Nat.pow_pos hq
    exact_mod_cast hp
  have hne : ((((q ^ S.card : ℕ) : ℝ)⁻¹ : ℝ) : ℂ) ≠ 0 := by
    simp only [ne_eq, Complex.ofReal_eq_zero, inv_eq_zero]
    exact hpos.ne'
  have h := rank_rhoLeft (codeState C S)
  rw [rhoLeft_codeState_of_isMDS hmds hd1 hq hSk hSd] at h
  rw [← h]
  have hdiag : ((((q ^ S.card : ℕ) : ℝ)⁻¹ : ℝ) : ℂ) • (1 : Matrix ({i // i ∈ S} → Fin q)
      ({i // i ∈ S} → Fin q) ℂ)
      = Matrix.diagonal (fun _ => ((((q ^ S.card : ℕ) : ℝ)⁻¹ : ℝ) : ℂ)) := by
    ext x y
    by_cases hxy : x = y <;> simp [hxy]
  rw [hdiag, Matrix.rank_diagonal,
    Fintype.card_congr (Equiv.subtypeUnivEquiv (fun _ => hne)),
    Fintype.card_fun, Fintype.card_coe, Fintype.card_fin]

/-- **MDS code states saturate the entropy–Schmidt-rank bound.**  Across a small
cut the entanglement entropy equals the logarithm of the Schmidt rank: the state
is maximally entangled at that bond. -/
theorem entanglementEntropy_codeState_eq_log_schmidtRank {C : Finset (Word n q)} {d : ℕ}
    (hmds : IsMDS C d) (hd1 : 1 ≤ d) (hq : 0 < q) {S : Finset (Fin n)}
    (hSk : S.card ≤ CutData.sdim n d) (hSd : S.card < d) :
    entanglementEntropy (codeState C S) = Real.log (schmidtRank (codeState C S)) := by
  rw [entanglementEntropy_codeState_of_isMDS hmds hd1 hq hSk hSd,
    schmidtRank_codeState_of_isMDS hmds hd1 hq hSk hSd]
  push_cast
  rw [Real.log_pow]

/-- The quantum mutual information across such a cut is sandwiched between
`|S| log q` and `2 |S| log q`, the extreme values allowed by the Schmidt rank. -/
theorem mutualInformation_codeState_of_isMDS {C : Finset (Word n q)} {d : ℕ}
    (hmds : IsMDS C d) (hd1 : 1 ≤ d) (hq : 0 < q) {S : Finset (Fin n)}
    (hSk : S.card ≤ CutData.sdim n d) (hSd : S.card < d) :
    S.card * Real.log q ≤ mutualInformation (codeState C S) ∧
      mutualInformation (codeState C S) ≤ 2 * (S.card * Real.log q) := by
  have hCne : C.Nonempty := by
    rw [← Finset.card_pos, hmds.2]
    exact Nat.pow_pos hq
  have hnorm := normalized_codeState hCne S
  have hleft : vnEntropy (rhoLeft (codeState C S)) = S.card * Real.log q :=
    entanglementEntropy_codeState_of_isMDS hmds hd1 hq hSk hSd
  have hright : 0 ≤ vnEntropy (rhoRight (codeState C S)) :=
    vnEntropy_nonneg (rhoRight_posSemidef (codeState C S)) (rhoRight_trace hnorm)
  have hub := mutualInformation_le_two_log_schmidtRank hnorm
  rw [schmidtRank_codeState_of_isMDS hmds hd1 hq hSk hSd] at hub
  constructor
  · rw [mutualInformation, hleft]
    linarith
  · refine hub.trans ?_
    push_cast at hub ⊢
    rw [Real.log_pow]

end CutIndexedSingleton