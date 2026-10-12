import Cryptography.DegreeTenCyclotomic.Semiprime
import Cryptography.NonabelianTypeChannel.Semiprime

/-!
# The which-factor wall vanishes for every abelian field

Cycle-2 result.  The degree-ten computation showed `I(N; ordered types) = I(N; unordered
types)`.  Here this is explained structurally and proved for every finite abelian group:

* `entropy_eq_pointwise` — entropy as an average surprisal.
* `entropy_pair_swap_symmetric` — under a swap symmetry, forgetting the order of a pair costs
  exactly `P(O₁ ≠ O₂)` bits, jointly with any swap-invariant readout.
* `which_factor_wall_of_swap_invariant` — the wall is zero whenever `c(gh) = c(hg)`.
* `which_factor_wall_coset` — hence for *every* Galois group read through its
  abelianization (`gh`, `hg` differ by a commutator); `which_factor_wall_abelian` — every
  readout of an abelian group.
* `D4_/A4_which_factor_wall_structural` — the catalog's nonabelian walls, recovered.
* `semi_which_factor_wall_structural` — the degree-ten instance, recovered without the
  56-cell table.
-/

namespace DegreeTen

open TypeChannel Finset Real

section Pointwise

variable {Ω α : Type*} [DecidableEq α]

/-- Entropy as an average of pointwise surprisals: `H(f) = (1/|S|) Σ_w −log₂ P(f = f w)`. -/
lemma entropy_eq_pointwise (S : Finset Ω) (f : Ω → α) :
    entropy S f = ∑ w ∈ S, -(logb 2 (prob S f (f w)) / S.card) := by
  unfold entropy
  rw [← Finset.sum_fiberwise_of_maps_to (g := f) (t := S.image f)
    (fun w hw => mem_image_of_mem f hw)]
  refine sum_congr rfl (fun a _ => ?_)
  rw [sum_congr rfl (fun w hw => by rw [(mem_filter.mp hw).2])]
  rw [sum_const, nsmul_eq_mul]
  unfold prob fiber
  ring

end Pointwise

section Swap

variable {α : Type*} [LinearOrder α]

/-- Forgetting the order of a pair. -/
def symm2 (o : α × α) : α × α := (min o.1 o.2, max o.1 o.2)

lemma symm2_eq_iff (o o' : α × α) : symm2 o = symm2 o' ↔ o = o' ∨ o = o'.swap := by
  obtain ⟨a, b⟩ := o
  obtain ⟨c, d⟩ := o'
  simp only [symm2, Prod.mk.injEq, Prod.swap_prod_mk]
  constructor
  · rintro ⟨h1, h2⟩
    rcases le_total a b with hab | hab <;> rcases le_total c d with hcd | hcd <;>
      simp_all
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨rfl, rfl⟩
    · exact ⟨min_comm _ _, max_comm _ _⟩

lemma symm2_diag_iff (o : α × α) (a : α) : symm2 o = (a, a) ↔ o = (a, a) := by
  have := symm2_eq_iff o (a, a)
  simp only [Prod.swap_prod_mk, or_self] at this
  rw [← this]; simp [symm2]

end Swap

section SwapEntropy

variable {Ω α β : Type*} [DecidableEq Ω] [LinearOrder α] [DecidableEq β]

/-- **Swap-symmetric pairs lose exactly the off-diagonal bit.**  If an involution `σ` of the
sample space fixes `Y` and swaps the two coordinates of `O`, then forgetting the order of
`O` lowers `H(Y, O)` by exactly `P(O₁ ≠ O₂)` bits. -/
theorem entropy_pair_swap_symmetric (S : Finset Ω) (σ : Ω → Ω) (hσS : ∀ w ∈ S, σ w ∈ S)
    (hσσ : ∀ w, σ (σ w) = w) (Y : Ω → β) (O : Ω → α × α) (hY : ∀ w ∈ S, Y (σ w) = Y w)
    (hO : ∀ w ∈ S, O (σ w) = (O w).swap) :
    entropy S (pairObs Y O) = entropy S (pairObs Y (fun w => symm2 (O w))) +
      ((S.filter (fun w => (O w).1 ≠ (O w).2)).card : ℝ) / S.card := by
  rw [entropy_eq_pointwise, entropy_eq_pointwise, Finset.card_filter, Nat.cast_sum,
    Finset.sum_div, ← Finset.sum_add_distrib]
  refine sum_congr rfl (fun w hw => ?_)
  set F1 := fiber S (pairObs Y O) (Y w, O w) with hF1
  set F2 := fiber S (pairObs Y (fun w => symm2 (O w))) (Y w, symm2 (O w)) with hF2
  have hw1 : w ∈ F1 := by simp [hF1, fiber, pairObs, hw]
  by_cases hd : (O w).1 = (O w).2
  · -- diagonal: the two fibres coincide
    have hOw : O w = ((O w).1, (O w).1) := Prod.ext rfl hd.symm
    have hF : F2 = F1 := by
      ext v
      simp only [hF1, hF2, fiber, pairObs, mem_filter, Prod.mk.injEq]
      rw [hOw, show symm2 ((O w).1, (O w).1) = ((O w).1, (O w).1) by simp [symm2],
        symm2_diag_iff]
    have : prob S (pairObs Y (fun w => symm2 (O w))) (pairObs Y (fun w => symm2 (O w)) w) =
        prob S (pairObs Y O) (pairObs Y O w) := by
      unfold prob
      change ((F2.card : ℝ)) / _ = (F1.card : ℝ) / _
      rw [hF]
    rw [this, if_neg (not_not.mpr hd)]
    simp
  · -- off-diagonal: the unordered fibre is two swapped copies of the ordered one
    set F1' := fiber S (pairObs Y O) (Y w, (O w).swap) with hF1'
    have hunion : F2 = F1 ∪ F1' := by
      ext v
      simp only [hF1, hF2, hF1', fiber, pairObs, mem_filter, mem_union, Prod.mk.injEq,
        symm2_eq_iff]
      tauto
    have hdisj : Disjoint F1 F1' := by
      rw [Finset.disjoint_left]
      intro v hv hv'
      simp only [hF1, hF1', fiber, pairObs, mem_filter, Prod.mk.injEq] at hv hv'
      have := hv.2.2.symm.trans hv'.2.2
      exact hd (by simpa using congrArg Prod.fst this)
    have himg : F1' = F1.image σ := by
      ext v
      simp only [hF1, hF1', fiber, pairObs, mem_filter, mem_image, Prod.mk.injEq]
      constructor
      · rintro ⟨hvS, hvY, hvO⟩
        refine ⟨σ v, ⟨hσS v hvS, by rw [hY v hvS]; exact hvY, ?_⟩, hσσ v⟩
        rw [hO v hvS, hvO, Prod.swap_swap]
      · rintro ⟨u, ⟨huS, huY, huO⟩, rfl⟩
        exact ⟨hσS u huS, by rw [hY u huS]; exact huY, by rw [hO u huS, huO]⟩
    have hcard' : F1'.card = F1.card := by
      rw [himg]
      exact Finset.card_image_of_injective _ (Function.LeftInverse.injective hσσ)
    have hcard2 : F2.card = 2 * F1.card := by
      rw [hunion, Finset.card_union_of_disjoint hdisj, hcard']; ring
    have hpos : (0 : ℝ) < F1.card := by exact_mod_cast Finset.card_pos.mpr ⟨w, hw1⟩
    have hS : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr ⟨w, hw⟩
    have hp2 : prob S (pairObs Y (fun w => symm2 (O w))) (pairObs Y (fun w => symm2 (O w)) w) =
        2 * prob S (pairObs Y O) (pairObs Y O w) := by
      unfold prob
      change ((F2.card : ℝ)) / _ = 2 * ((F1.card : ℝ) / _)
      rw [hcard2]
      push_cast; ring
    rw [hp2, if_pos hd, Real.logb_mul (by norm_num) (by unfold prob; positivity),
      logb2_two]
    push_cast
    field_simp
    ring

end SwapEntropy

section WhichFactor

variable {G : Type*} [Group G] [DecidableEq G] {κ τ : Type*} [DecidableEq κ] [LinearOrder τ]

/-- The which-factor readouts for a semiprime `N = pq` with Frobenius classes `(g, h)`. -/
def ordPair (T : G → τ) (q : G × G) : τ × τ := (T q.1, T q.2)

/-- **The which-factor wall vanishes whenever the residue readout cannot tell `gh` from
`hg`.**  For any finite sample `S` of a group, any readout `c` with `c(gh) = c(hg)` on `S`
and any linearly ordered type readout `T`:
`I(c(gh) ; (T g, T h)) = I(c(gh) ; {T g, T h})`. -/
theorem which_factor_wall_of_swap_invariant (S : Finset G) (c : G → κ) (T : G → τ)
    (hc : ∀ g ∈ S, ∀ h ∈ S, c (g * h) = c (h * g)) :
    mutualInfo (S ×ˢ S) (fun q : G × G => c (q.1 * q.2)) (ordPair T) =
      mutualInfo (S ×ˢ S) (fun q : G × G => c (q.1 * q.2))
        (fun q => symm2 (ordPair T q)) := by
  have hσS : ∀ w ∈ S ×ˢ S, Prod.swap w ∈ S ×ˢ S :=
    fun w hw => by simpa [and_comm] using hw
  have hσσ : ∀ w : G × G, w.swap.swap = w := Prod.swap_swap
  have hO : ∀ w ∈ S ×ˢ S, ordPair T w.swap = (ordPair T w).swap := fun _ _ => rfl
  have hX : ∀ w ∈ S ×ˢ S, c (w.swap.1 * w.swap.2) = c (w.1 * w.2) := by
    intro w hw
    obtain ⟨h1, h2⟩ := mem_product.mp hw
    exact hc w.2 h2 w.1 h1
  have h1 := entropy_pair_swap_symmetric (S ×ˢ S) Prod.swap hσS hσσ
    (fun q : G × G => c (q.1 * q.2)) (ordPair T) hX hO
  have h2 := entropy_pair_swap_symmetric (S ×ˢ S) Prod.swap hσS hσσ
    (fun _ : G × G => ()) (ordPair T) (fun _ _ => rfl) hO
  have hu1 : entropy (S ×ˢ S) (pairObs (fun _ : G × G => ()) (ordPair T)) =
      entropy (S ×ˢ S) (ordPair T) :=
    entropy_comp_of_injOn (φ := fun o => ((), o)) (fun _ _ _ _ h => by simpa using h)
  have hu2 : entropy (S ×ˢ S)
      (pairObs (fun _ : G × G => ()) (fun w => symm2 (ordPair T w))) =
      entropy (S ×ˢ S) (fun w => symm2 (ordPair T w)) :=
    entropy_comp_of_injOn (φ := fun o => ((), o)) (fun _ _ _ _ h => by simpa using h)
  rw [hu1, hu2] at h2
  unfold mutualInfo
  linarith

/-- **The which-factor wall vanishes for every Galois group, abelian or not**, when the
residue is read through the abelianization: `gh` and `hg` differ by the commutator
`[g, h] ∈ G'`, so they lie in the same coset of the derived subgroup. -/
theorem which_factor_wall_coset {S N : Finset G} {c : G → κ} (hd : IsDerivedFinset S N)
    (hc : IsCosetReadout S N c) (hS : IsSubgroupFinset S) (T : G → τ) :
    mutualInfo (S ×ˢ S) (fun q : G × G => c (q.1 * q.2)) (ordPair T) =
      mutualInfo (S ×ˢ S) (fun q : G × G => c (q.1 * q.2))
        (fun q => symm2 (ordPair T q)) := by
  refine which_factor_wall_of_swap_invariant S c T (fun g hg h hh => ?_)
  refine (hc _ (hS.mul_mem g hg h hh) _ (hS.mul_mem h hh g hg)).mpr ?_
  have := hd.commutator_mem g hg h hh
  simpa [mul_inv_rev, mul_assoc] using this

/-- **Abelian case.**  For a finite abelian Galois group the wall vanishes for every residue
readout whatsoever. -/
theorem which_factor_wall_abelian {A : Type*} [CommGroup A] [Fintype A] [DecidableEq A]
    (c : A → κ) (T : A → τ) :
    mutualInfo (univ ×ˢ univ) (fun q : A × A => c (q.1 * q.2)) (ordPair T) =
      mutualInfo (univ ×ˢ univ) (fun q : A × A => c (q.1 * q.2))
        (fun q => symm2 (ordPair T q)) :=
  which_factor_wall_of_swap_invariant univ c T (fun g _ h _ => by rw [mul_comm])

/-- The degree-ten which-factor wall, now as an instance of the general abelian law
(independently of the explicit 56-cell computation). -/
theorem semi_which_factor_wall_structural :
    mutualInfo SP semiN semiOrd = mutualInfo SP semiN semiPair :=
  which_factor_wall_abelian (A := U11) resid frobType

/-- The catalog's nonabelian `D₄` which-factor wall, recovered structurally. -/
theorem D4_which_factor_wall_structural :
    mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) ordType
      = mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) symType :=
  which_factor_wall_coset D4_derived D4_coset D4_isSubgroup typeCode

/-- The catalog's nonabelian `A₄` which-factor wall, recovered structurally. -/
theorem A4_which_factor_wall_structural :
    mutualInfo (A4 ×ˢ A4) (prodCoset pairIdx) ordType
      = mutualInfo (A4 ×ˢ A4) (prodCoset pairIdx) symType :=
  which_factor_wall_coset A4_derived A4_coset A4_isSubgroup typeCode

end WhichFactor

end DegreeTen