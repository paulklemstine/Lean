import Novelty.IITTensorNetworkMPS
import Novelty.IntegratedInformation

/-! # Integrated information of a tensor network state

We attach to a quantum state of a chain of `n` sites with local dimension `d`
the integrated information `Φ` of Tononi's theory, formalized through the
catalog's `IntegratedInformation.CausalStructure`: the admissible cuts are the
`n - 1` bipartitions of the chain into a left block and a right block, and the
information destroyed by a cut is the quantum mutual information carried across
that cut by the state.  Thus, *by construction*,

`Φ = min over bipartitions of the quantum mutual information`,

and the substantive content is in the theorems relating `Φ` to the tensor
network data:

* `phi_le_mutualInformation`, `exists_minimal_cut` : `Φ` is the minimum of the
  mutual information over bipartitions;
* `phi_eq_zero_iff_exists_product_cut` : `Φ = 0` exactly when the state
  factorizes (Schmidt rank one) across some cut, i.e. exactly when the state is
  *reducible* in the sense of IIT;
* `phi_le_two_log_of_bondDim` : a cut of bond dimension `χ` caps `Φ` at
  `2 log χ` — an MPS with bond dimension `2` has `Φ ≤ 2 log 2 = log 4`;
* `phi_ghz`, `phi_ghz_saturates_bond_bound` : the GHZ chain state has
  `Φ = 2 log d` where `d` is both its bond dimension
  (`hasBondDim_chainCutMatrix_ghz`) and its Schmidt rank at every cut; for
  `d = 2` this gives `Φ = 2 log 2 = log 4`, twice the logarithm of the Schmidt
  rank `2` (`phi_ghz_qubits`).
-/

open Finset Matrix
open scoped ComplexOrder

namespace IITTensorNetwork

section Chain

variable {n d : ℕ}

/-- Glue a configuration of the first `l` sites and a configuration of the
remaining `n - l` sites into a configuration of the whole chain. -/
def glue (l : ℕ) (hl : l ≤ n) (f : Fin l → Fin d) (g : Fin (n - l) → Fin d) : Fin n → Fin d :=
  fun i => if h : (i : ℕ) < l then f ⟨i, h⟩ else g ⟨(i : ℕ) - l, by have := i.isLt; omega⟩

/-- The restriction of a chain configuration to the first `l` sites. -/
def splitL (l : ℕ) (hl : l ≤ n) (s : Fin n → Fin d) : Fin l → Fin d :=
  fun i => s ⟨i, by have := i.isLt; omega⟩

/-- The restriction of a chain configuration to the last `n - l` sites. -/
def splitR (l : ℕ) (hl : l ≤ n) (s : Fin n → Fin d) : Fin (n - l) → Fin d :=
  fun j => s ⟨l + j, by have := j.isLt; omega⟩

lemma splitL_glue (l : ℕ) (hl : l ≤ n) (f : Fin l → Fin d) (g : Fin (n - l) → Fin d) :
    splitL l hl (glue l hl f g) = f := by
  funext i
  have h : ((⟨i, by have := i.isLt; omega⟩ : Fin n) : ℕ) < l := i.isLt
  simp [splitL, glue, h]

lemma splitR_glue (l : ℕ) (hl : l ≤ n) (f : Fin l → Fin d) (g : Fin (n - l) → Fin d) :
    splitR l hl (glue l hl f g) = g := by
  funext j
  have h : ¬ (((⟨l + j, by have := j.isLt; omega⟩ : Fin n) : ℕ) < l) := by
    simp only []
    omega
  simp only [splitR, glue, dif_neg h]
  congr 1
  apply Fin.ext
  simp

lemma glue_splitL_splitR (l : ℕ) (hl : l ≤ n) (s : Fin n → Fin d) :
    glue l hl (splitL l hl s) (splitR l hl s) = s := by
  funext i
  by_cases h : (i : ℕ) < l
  · simp [glue, splitL, h]
  · simp only [glue, dif_neg h, splitR]
    congr 1
    apply Fin.ext
    simp only []
    omega

/-- Splitting a chain configuration at position `l` is a bijection. -/
def chainEquiv (l : ℕ) (hl : l ≤ n) :
    (Fin n → Fin d) ≃ (Fin l → Fin d) × (Fin (n - l) → Fin d) where
  toFun s := (splitL l hl s, splitR l hl s)
  invFun p := glue l hl p.1 p.2
  left_inv s := glue_splitL_splitR l hl s
  right_inv p := by
    ext1
    · exact splitL_glue l hl p.1 p.2
    · exact splitR_glue l hl p.1 p.2

/-- The coefficient matrix of a chain state across the cut at position `l`. -/
noncomputable def chainCutMatrix (psi : (Fin n → Fin d) → ℂ) (l : ℕ) (hl : l ≤ n) :
    Matrix (Fin l → Fin d) (Fin (n - l) → Fin d) ℂ :=
  Matrix.of fun f g => psi (glue l hl f g)

/-- A normalized chain state has normalized cut matrices. -/
theorem normalized_chainCutMatrix {psi : (Fin n → Fin d) → ℂ}
    (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (l : ℕ) (hl : l ≤ n) :
    Normalized (chainCutMatrix psi l hl) := by
  have hsum : ∑ p : (Fin l → Fin d) × (Fin (n - l) → Fin d),
      ‖psi ((chainEquiv l hl).symm p)‖ ^ 2 = ∑ s, ‖psi s‖ ^ 2 :=
    Equiv.sum_comp (chainEquiv l hl).symm (fun s => ‖psi s‖ ^ 2)
  rw [Fintype.sum_prod_type, hpsi] at hsum
  exact hsum

/-- The IIT causal structure of a chain state: the admissible cuts are the
`n - 1` bipartitions into a left block and a right block, and the information
lost at a cut is the quantum mutual information across it. -/
noncomputable def chainCausalStructure {psi : (Fin n → Fin d) → ℂ}
    (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) : IntegratedInformation.CausalStructure where
  Cut := Fin (n - 1)
  cutNonempty := ⟨⟨0, by omega⟩⟩
  loss p := mutualInformation (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega))
  loss_nonneg p :=
    mutualInformation_nonneg (normalized_chainCutMatrix hpsi ((p : ℕ) + 1) (by
      have := p.isLt; omega))

/-- The integrated information of a chain state: the minimum, over all
bipartitions of the chain, of the quantum mutual information across the cut. -/
noncomputable def Phi {psi : (Fin n → Fin d) → ℂ} (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) :
    ℝ :=
  IntegratedInformation.Phi (chainCausalStructure hpsi hn)

variable {psi : (Fin n → Fin d) → ℂ}

/-- `Φ` is bounded above by the mutual information across every cut. -/
theorem phi_le_mutualInformation (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n)
    (p : Fin (n - 1)) :
    Phi hpsi hn
      ≤ mutualInformation (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega)) :=
  IntegratedInformation.phi_le_loss (chainCausalStructure hpsi hn) p

/-- Some bipartition realizes `Φ`: `Φ` is the *minimum* of the quantum mutual
information over bipartitions. -/
theorem exists_minimal_cut (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) :
    ∃ p : Fin (n - 1),
      mutualInformation (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega))
        = Phi hpsi hn :=
  IntegratedInformation.exists_minimum_information_cut (chainCausalStructure hpsi hn)

/-- Every lower bound for the mutual information of all cuts bounds `Φ`. -/
theorem le_phi (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) {a : ℝ}
    (h : ∀ p : Fin (n - 1),
      a ≤ mutualInformation (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega))) :
    a ≤ Phi hpsi hn :=
  IntegratedInformation.le_phi (chainCausalStructure hpsi hn) h

/-- Integrated information is nonnegative. -/
theorem phi_nonneg (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) : 0 ≤ Phi hpsi hn :=
  IntegratedInformation.phi_nonneg (chainCausalStructure hpsi hn)

/-- **Reducibility.**  The integrated information of a chain state vanishes
exactly when the state is a product state (Schmidt rank one) across some
bipartition. -/
theorem phi_eq_zero_iff_exists_product_cut (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) :
    Phi hpsi hn = 0 ↔
      ∃ p : Fin (n - 1),
        schmidtRank (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega)) = 1 := by
  rw [Phi, IntegratedInformation.phi_eq_zero_iff]
  constructor
  · rintro ⟨p, hp⟩
    exact ⟨p, (mutualInformation_eq_zero_iff_schmidtRank_eq_one
      (normalized_chainCutMatrix hpsi _ _)).mp hp⟩
  · rintro ⟨p, hp⟩
    exact ⟨p, (mutualInformation_eq_zero_iff_schmidtRank_eq_one
      (normalized_chainCutMatrix hpsi _ _)).mpr hp⟩

/-- **`Φ` is the minimum of the quantum mutual information over bipartitions.**
This is the conjecture of the project, in the precise form in which it holds:
`Φ` is the least element of the set of mutual informations across cuts. -/
theorem phi_isLeast_mutualInformation (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) :
    IsLeast (Set.range fun p : Fin (n - 1) =>
      mutualInformation (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega)))
      (Phi hpsi hn) := by
  obtain ⟨p, hp⟩ := exists_minimal_cut hpsi hn
  refine ⟨⟨p, hp⟩, ?_⟩
  rintro x ⟨q, rfl⟩
  exact phi_le_mutualInformation hpsi hn q

/-- **Irreducibility criterion.**  A chain state has strictly positive
integrated information exactly when it is entangled (Schmidt rank at least two)
across every bipartition. -/
theorem phi_pos_iff_all_cuts_entangled (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) :
    0 < Phi hpsi hn ↔
      ∀ p : Fin (n - 1),
        2 ≤ schmidtRank (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega)) := by
  constructor
  · intro hpos p
    have hne : Phi hpsi hn ≠ 0 := ne_of_gt hpos
    have hrk : schmidtRank (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega)) ≠ 1 :=
      fun h => hne ((phi_eq_zero_iff_exists_product_cut hpsi hn).mpr ⟨p, h⟩)
    have hpos1 := schmidtRank_pos (normalized_chainCutMatrix hpsi ((p : ℕ) + 1)
      (by have := p.isLt; omega))
    omega
  · intro hall
    rcases lt_or_eq_of_le (phi_nonneg hpsi hn) with h | h
    · exact h
    · exfalso
      obtain ⟨p, hp⟩ := (phi_eq_zero_iff_exists_product_cut hpsi hn).mp h.symm
      have := hall p
      omega

/-- **Bond dimension caps integrated information.**  If the coefficient matrix
at some bipartition factors through a `χ`-dimensional bond, then `Φ ≤ 2 log χ`.
In particular a matrix product state of bond dimension `2` has `Φ ≤ 2 log 2`. -/
theorem phi_le_two_log_of_bondDim (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) (hn : 2 ≤ n) {χ : ℕ}
    (p : Fin (n - 1))
    (hbond : HasBondDim (chainCutMatrix psi ((p : ℕ) + 1) (by have := p.isLt; omega)) χ) :
    Phi hpsi hn ≤ 2 * Real.log χ :=
  le_trans (phi_le_mutualInformation hpsi hn p)
    (mutualInformation_le_two_log_bondDim (normalized_chainCutMatrix hpsi _ _) hbond)

end Chain

section GHZ

variable {n d : ℕ}

/-- The GHZ state of a chain of `n` sites with local dimension `d`: an equal
superposition of the `d` constant configurations. -/
noncomputable def ghzState (n d : ℕ) : (Fin n → Fin d) → ℂ :=
  fun s => if ∀ i j, s i = s j then (((Real.sqrt d)⁻¹ : ℝ) : ℂ) else 0

/-- The constant configuration of a block of `k` sites with common value `x`. -/
def constCfg (k d : ℕ) : Fin d → (Fin k → Fin d) := fun x _ => x

lemma constCfg_injective {k : ℕ} (hk : 0 < k) : Function.Injective (constCfg k d) := by
  intro x y h
  exact congrFun h ⟨0, hk⟩

/-- A glued configuration is constant exactly when both blocks are constant with
the same value. -/
lemma glue_const_iff {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) (f : Fin l → Fin d)
    (g : Fin (n - l) → Fin d) :
    (∀ i j, glue l hl f g i = glue l hl f g j)
      ↔ ∃ x, f = constCfg l d x ∧ g = constCfg (n - l) d x := by
  constructor
  · intro h
    refine ⟨glue l hl f g ⟨0, by omega⟩, ?_, ?_⟩
    · funext i
      simp only [constCfg]
      have hfi : glue l hl f g ⟨(i : ℕ), by have := i.isLt; omega⟩ = f i := by
        simp [glue, i.isLt]
      rw [← hfi]
      exact h _ _
    · funext j
      simp only [constCfg]
      have hgj : glue l hl f g ⟨l + (j : ℕ), by have := j.isLt; omega⟩ = g j := by
        have hlt : ¬ (l + (j : ℕ) < l) := by omega
        simp only [glue, dif_neg hlt]
        congr 1
        apply Fin.ext
        simp
      rw [← hgj]
      exact h _ _
  · rintro ⟨x, rfl, rfl⟩
    have hval : ∀ i : Fin n, glue l hl (constCfg l d x) (constCfg (n - l) d x) i = x := by
      intro i
      by_cases h : (i : ℕ) < l <;> simp [glue, constCfg, h]
    intro i j
    rw [hval i, hval j]

/-- **The GHZ chain state, cut open, is maximally entangled of Schmidt rank
`d`.** -/
theorem chainCutMatrix_ghz {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) :
    chainCutMatrix (ghzState n d) l hl
      = maxEnt (constCfg l d) (constCfg (n - l) d) := by
  ext f g
  have hcard : (Fintype.card (Fin d) : ℝ) = (d : ℝ) := by simp
  have hRHS : maxEnt (constCfg l d) (constCfg (n - l) d) f g
      = (((Real.sqrt d)⁻¹ : ℝ) : ℂ)
        * ∑ x : Fin d, (if constCfg l d x = f then (1 : ℂ) else 0)
            * (if constCfg (n - l) d x = g then (1 : ℂ) else 0) := by
    simp only [maxEnt, maxEntState, Matrix.smul_apply, Matrix.mul_apply, isoMatrix,
      Matrix.conjTranspose_apply, RCLike.star_def, smul_eq_mul, hcard]
    congr 1
    refine Finset.sum_congr rfl fun x _ => ?_
    by_cases h : constCfg (n - l) d x = g <;> simp [h]
  rw [hRHS]
  simp only [chainCutMatrix, Matrix.of_apply, ghzState]
  by_cases hconst : ∀ i j, glue l hl f g i = glue l hl f g j
  · obtain ⟨x0, hx0f, hx0g⟩ := (glue_const_iff hl hl1 f g).mp hconst
    rw [if_pos hconst, Finset.sum_eq_single x0]
    · simp [hx0f, hx0g]
    · intro x _ hx
      have : constCfg l d x ≠ f := by
        rw [hx0f]
        exact fun h => hx (constCfg_injective (by omega) h)
      simp [this]
    · intro h
      exact absurd (Finset.mem_univ x0) h
  · rw [if_neg hconst]
    have hzero : ∀ x : Fin d, (if constCfg l d x = f then (1 : ℂ) else 0)
        * (if constCfg (n - l) d x = g then (1 : ℂ) else 0) = 0 := by
      intro x
      by_cases h1 : constCfg l d x = f
      · by_cases h2 : constCfg (n - l) d x = g
        · exact absurd ((glue_const_iff hl hl1 f g).mpr ⟨x, h1.symm, h2.symm⟩) hconst
        · simp [h2]
      · simp [h1]
    rw [Finset.sum_congr rfl (fun x _ => hzero x)]
    simp

/-- **The GHZ chain state is a matrix product state of bond dimension `d`.** -/
theorem hasBondDim_chainCutMatrix_ghz {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) :
    HasBondDim (chainCutMatrix (ghzState n d) l hl) d := by
  rw [chainCutMatrix_ghz hl hl1]
  exact hasBondDim_maxEnt _ _

/-- The Schmidt rank of the GHZ chain state at every bipartition equals `d`. -/
theorem schmidtRank_chainCutMatrix_ghz {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) (hlr : l < n)
    (hd : 0 < d) :
    schmidtRank (chainCutMatrix (ghzState n d) l hl) = d := by
  have hu : Function.Injective (constCfg l d) := constCfg_injective (by omega)
  have hv : Function.Injective (constCfg (n - l) d) := constCfg_injective (by omega)
  have hcard : 0 < Fintype.card (Fin d) := by simpa using hd
  rw [chainCutMatrix_ghz hl hl1, schmidtRank_maxEnt hu hv hcard, Fintype.card_fin]

/-- The GHZ chain state is normalized. -/
theorem normalized_chainCutMatrix_ghz {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) (hlr : l < n)
    (hd : 0 < d) : Normalized (chainCutMatrix (ghzState n d) l hl) := by
  have hu : Function.Injective (constCfg l d) := constCfg_injective (by omega)
  have hv : Function.Injective (constCfg (n - l) d) := constCfg_injective (by omega)
  have hcard : 0 < Fintype.card (Fin d) := by simpa using hd
  rw [chainCutMatrix_ghz hl hl1]
  exact normalized_maxEnt hu hv hcard

/-- **Mutual information of the GHZ chain state.**  Across every bipartition the
GHZ state carries `2 log d` of quantum mutual information, exactly twice the
logarithm of its Schmidt rank. -/
theorem mutualInformation_chainCutMatrix_ghz {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l) (hlr : l < n)
    (hd : 0 < d) :
    mutualInformation (chainCutMatrix (ghzState n d) l hl) = 2 * Real.log d := by
  have hu : Function.Injective (constCfg l d) := constCfg_injective (by omega)
  have hv : Function.Injective (constCfg (n - l) d) := constCfg_injective (by omega)
  have hcard : 0 < Fintype.card (Fin d) := by simpa using hd
  rw [chainCutMatrix_ghz hl hl1, mutualInformation_maxEnt hu hv hcard,
    schmidtRank_maxEnt hu hv hcard, Fintype.card_fin]

/-- The GHZ chain state is a normalized state of the whole chain. -/
theorem ghzState_normalized (hn : 1 ≤ n) (hd : 0 < d) :
    ∑ s, ‖ghzState n d s‖ ^ 2 = 1 := by
  have hcount : (Finset.univ.filter (fun s : Fin n → Fin d => ∀ i j, s i = s j)).card = d := by
    have himage : (Finset.univ.filter (fun s : Fin n → Fin d => ∀ i j, s i = s j))
        = Finset.image (constCfg n d) Finset.univ := by
      ext s
      constructor
      · intro hs
        have h : ∀ i j, s i = s j := (Finset.mem_filter.mp hs).2
        refine Finset.mem_image.mpr ⟨s ⟨0, by omega⟩, Finset.mem_univ _, ?_⟩
        funext i
        exact (h _ _).symm
      · intro hs
        obtain ⟨x, -, rfl⟩ := Finset.mem_image.mp hs
        exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, fun i j => rfl⟩
    rw [himage, Finset.card_image_of_injective _ (constCfg_injective (k := n) (by omega)),
      Finset.card_univ, Fintype.card_fin]
  have hd' : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  have hval : ∀ s : Fin n → Fin d, ‖ghzState n d s‖ ^ 2
      = if (∀ i j, s i = s j) then ((d : ℝ))⁻¹ else 0 := by
    intro s
    by_cases h : ∀ i j, s i = s j
    · rw [if_pos h]
      simp only [ghzState, if_pos h, Complex.norm_real, Real.norm_eq_abs,
        abs_of_nonneg (by positivity : (0:ℝ) ≤ (Real.sqrt d)⁻¹)]
      rw [sq, ← mul_inv, Real.mul_self_sqrt hd'.le]
    · simp [ghzState, h]
  rw [Finset.sum_congr rfl (fun s _ => hval s), ← Finset.sum_filter, Finset.sum_const, hcount,
    nsmul_eq_mul, mul_inv_cancel₀ (ne_of_gt hd')]

/-- **Integrated information of the GHZ chain state.**  Its `Φ` is exactly
`2 log d`: the minimum over bipartitions of the quantum mutual information is
attained at every cut and equals twice the logarithm of the Schmidt rank. -/
theorem phi_ghz (hn : 2 ≤ n) (hd : 0 < d) :
    Phi (ghzState_normalized (by omega) hd) hn = 2 * Real.log d := by
  have hloss : ∀ p : Fin (n - 1),
      mutualInformation (chainCutMatrix (ghzState n d) ((p : ℕ) + 1)
        (by have := p.isLt; omega)) = 2 * Real.log d := by
    intro p
    have hp := p.isLt
    exact mutualInformation_chainCutMatrix_ghz (by omega) (by omega) (by omega) hd
  refine le_antisymm ?_ (le_phi _ hn (fun p => (hloss p).ge))
  obtain ⟨p, hp⟩ := exists_minimal_cut (ghzState_normalized (n := n) (d := d) (by omega) hd) hn
  rw [← hp, hloss p]

/-- **GHZ saturates the bond-dimension bound.**  For the GHZ chain state the
general cap `Φ ≤ 2 log χ` of `phi_le_two_log_of_bondDim`, applied with the bond
dimension `χ = d`, is an equality. -/
theorem phi_ghz_saturates_bond_bound (hn : 2 ≤ n) (hd : 0 < d) :
    Phi (ghzState_normalized (n := n) (d := d) (by omega) hd) hn = 2 * Real.log d
      ∧ ∀ p : Fin (n - 1),
        HasBondDim (chainCutMatrix (ghzState n d) ((p : ℕ) + 1)
          (by have := p.isLt; omega)) d := by
  refine ⟨phi_ghz hn hd, fun p => ?_⟩
  have := p.isLt
  exact hasBondDim_chainCutMatrix_ghz (by omega) (by omega)

/-- **Bond dimension two: `Φ` matches the Schmidt rank.**  For the GHZ chain
state with local dimension `2` — a matrix product state of bond dimension `2` —
the integrated information equals `2 log 2 = log 4`, that is, twice the
logarithm of the Schmidt rank `2` at every bipartition. -/
theorem phi_ghz_qubits (hn : 2 ≤ n) :
    Phi (ghzState_normalized (n := n) (d := 2) (by omega) (by norm_num)) hn
      = 2 * Real.log (schmidtRank (chainCutMatrix (ghzState n 2) 1 (by omega))) := by
  rw [phi_ghz hn (by norm_num),
    schmidtRank_chainCutMatrix_ghz (l := 1) (by omega) le_rfl (by omega) (by norm_num)]

end GHZ

end IITTensorNetwork