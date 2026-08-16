import Mathlib
import Novelty.EmergentGeometryEntropyCone

/-!
# The five-party cyclic inequality of the holographic entropy cone

Subadditivity and strong subadditivity hold for *every* quantum state, and
monogamy of mutual information (proved in `Novelty.EmergentGeometryEntropyCone`)
is the first inequality special to geometric states.  The next genuinely new
family starts at five parties with the **cyclic inequality**

`∑_{j} S(A_j A_{j+1} A_{j+2}) ≥ ∑_{j} S(A_j A_{j+1}) + S(A_0A_1A_2A_3A_4)`,

indices mod `5`.  Here it is proved for min-cut entropies of an arbitrary finite
bulk geometry.

The proof follows the *contraction map* pattern: five minimal surfaces (one for
each cyclic triple) are recombined into six new regions — five "cyclic minority"
regions and their union — by the single Boolean rule

`cyc c₀ c₁ c₂ c₃ c₄ = c₄ ∧ ¬c₂ ∧ (c₀ ∨ (c₁ ∧ ¬c₃))`

applied to the five cyclic rotations of the membership pattern.  The two facts
that make this work are `sepBit_cyclic5` (a `1024`-case Boolean contraction
inequality) and `cyc_boundary` (the recombined regions have exactly the right
boundary traces).  The rule is *not* an intersection: no combination built from
plain intersections and unions can satisfy the contraction inequality.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V]

/-! ## The cyclic contraction rule -/

/-- The Boolean rule producing the region assigned to the pair `A₀A₁` from the
membership pattern in the five triple-regions. -/
def cyc (c₀ c₁ c₂ c₃ c₄ : Bool) : Bool := c₄ && !c₂ && (c₀ || (c₁ && !c₃))

/-- **The cyclic contraction inequality.**  Five cyclic rotations of `cyc`
together with the union separate any pair of bulk cells at most as often as the
five original regions do.  Verified over all `1024` Boolean configurations. -/
lemma sepBit_cyclic5 (a₀ a₁ a₂ a₃ a₄ b₀ b₁ b₂ b₃ b₄ : Bool) :
    sepBit (cyc a₀ a₁ a₂ a₃ a₄) (cyc b₀ b₁ b₂ b₃ b₄)
      + sepBit (cyc a₁ a₂ a₃ a₄ a₀) (cyc b₁ b₂ b₃ b₄ b₀)
      + sepBit (cyc a₂ a₃ a₄ a₀ a₁) (cyc b₂ b₃ b₄ b₀ b₁)
      + sepBit (cyc a₃ a₄ a₀ a₁ a₂) (cyc b₃ b₄ b₀ b₁ b₂)
      + sepBit (cyc a₄ a₀ a₁ a₂ a₃) (cyc b₄ b₀ b₁ b₂ b₃)
      + sepBit (a₀ || a₁ || a₂ || a₃ || a₄) (b₀ || b₁ || b₂ || b₃ || b₄)
      ≤ sepBit a₀ b₀ + sepBit a₁ b₁ + sepBit a₂ b₂ + sepBit a₃ b₃ + sepBit a₄ b₄ := by
  revert a₀ a₁ a₂ a₃ a₄ b₀ b₁ b₂ b₃ b₄; decide

/-- At most one of five Boolean values is `true`: the pointwise form of pairwise
disjointness of five boundary regions. -/
def AtMostOneTrue (a₀ a₁ a₂ a₃ a₄ : Bool) : Prop :=
  a₀.toNat + a₁.toNat + a₂.toNat + a₃.toNat + a₄.toNat ≤ 1

instance (a₀ a₁ a₂ a₃ a₄ : Bool) : Decidable (AtMostOneTrue a₀ a₁ a₂ a₃ a₄) := by
  unfold AtMostOneTrue; infer_instance

/-- **Boundary traces of the recombined regions.**  On the boundary, where the
five minimal surfaces trace out the cyclic triples, the contraction rule traces
out exactly the cyclic pairs. -/
lemma cyc_boundary (a₀ a₁ a₂ a₃ a₄ : Bool) (h : AtMostOneTrue a₀ a₁ a₂ a₃ a₄) :
    cyc (a₀ || a₁ || a₂) (a₁ || a₂ || a₃) (a₂ || a₃ || a₄) (a₃ || a₄ || a₀)
        (a₄ || a₀ || a₁) = (a₀ || a₁) := by
  revert a₀ a₁ a₂ a₃ a₄
  decide

/-- The cut-area form of the cyclic contraction inequality. -/
theorem cutWeight_cyclic5 (G : BulkGraph V) (f₀ f₁ f₂ f₃ f₄ : Region V) :
    cutWeight G (fun v => cyc (f₀ v) (f₁ v) (f₂ v) (f₃ v) (f₄ v))
      + cutWeight G (fun v => cyc (f₁ v) (f₂ v) (f₃ v) (f₄ v) (f₀ v))
      + cutWeight G (fun v => cyc (f₂ v) (f₃ v) (f₄ v) (f₀ v) (f₁ v))
      + cutWeight G (fun v => cyc (f₃ v) (f₄ v) (f₀ v) (f₁ v) (f₂ v))
      + cutWeight G (fun v => cyc (f₄ v) (f₀ v) (f₁ v) (f₂ v) (f₃ v))
      + cutWeight G (fun v => f₀ v || f₁ v || f₂ v || f₃ v || f₄ v)
      ≤ cutWeight G f₀ + cutWeight G f₁ + cutWeight G f₂ + cutWeight G f₃
        + cutWeight G f₄ := by
  have h := cutWeight_comb G ![f₀, f₁, f₂, f₃, f₄]
    ![fun v => cyc (f₀ v) (f₁ v) (f₂ v) (f₃ v) (f₄ v),
      fun v => cyc (f₁ v) (f₂ v) (f₃ v) (f₄ v) (f₀ v),
      fun v => cyc (f₂ v) (f₃ v) (f₄ v) (f₀ v) (f₁ v),
      fun v => cyc (f₃ v) (f₄ v) (f₀ v) (f₁ v) (f₂ v),
      fun v => cyc (f₄ v) (f₀ v) (f₁ v) (f₂ v) (f₃ v),
      fun v => f₀ v || f₁ v || f₂ v || f₃ v || f₄ v]
    (by
      intro u v _
      simp only [Fin.sum_univ_five, Fin.sum_univ_six, Matrix.cons_val_zero,
        Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons,
        Matrix.cons_val_three, Matrix.cons_val_four]
      exact sepBit_cyclic5 (f₀ u) (f₁ u) (f₂ u) (f₃ u) (f₄ u)
        (f₀ v) (f₁ v) (f₂ v) (f₃ v) (f₄ v))
  simpa [Fin.sum_univ_five, Fin.sum_univ_six, add_assoc] using h

/-! ## The entropy inequality -/

variable [DecidableEq V]

/-- **The five-party cyclic holographic entropy inequality.**  For pairwise
disjoint boundary regions `A₀,…,A₄`,

`S(A₀A₁) + S(A₁A₂) + S(A₂A₃) + S(A₃A₄) + S(A₄A₀) + S(A₀A₁A₂A₃A₄)`
`  ≤ S(A₀A₁A₂) + S(A₁A₂A₃) + S(A₂A₃A₄) + S(A₃A₄A₀) + S(A₄A₀A₁)`.

Unlike subadditivity and strong subadditivity, this inequality is *false* for
general quantum states; it is a signature of geometric (holographic)
entanglement, and it is not implied by monogamy of mutual information. -/
theorem entropy_cyclic5 (M : HoloModel V) (A₀ A₁ A₂ A₃ A₄ : Region V)
    (hd : ∀ v, AtMostOneTrue (A₀ v) (A₁ v) (A₂ v) (A₃ v) (A₄ v)) :
    entropy M (fun v => A₀ v || A₁ v) + entropy M (fun v => A₁ v || A₂ v)
        + entropy M (fun v => A₂ v || A₃ v) + entropy M (fun v => A₃ v || A₄ v)
        + entropy M (fun v => A₄ v || A₀ v)
        + entropy M (fun v => A₀ v || A₁ v || A₂ v || A₃ v || A₄ v)
      ≤ entropy M (fun v => A₀ v || A₁ v || A₂ v)
        + entropy M (fun v => A₁ v || A₂ v || A₃ v)
        + entropy M (fun v => A₂ v || A₃ v || A₄ v)
        + entropy M (fun v => A₃ v || A₄ v || A₀ v)
        + entropy M (fun v => A₄ v || A₀ v || A₁ v) := by
  obtain ⟨f₀, hf₀, e₀⟩ := exists_minimal_surface M (fun v => A₀ v || A₁ v || A₂ v)
  obtain ⟨f₁, hf₁, e₁⟩ := exists_minimal_surface M (fun v => A₁ v || A₂ v || A₃ v)
  obtain ⟨f₂, hf₂, e₂⟩ := exists_minimal_surface M (fun v => A₂ v || A₃ v || A₄ v)
  obtain ⟨f₃, hf₃, e₃⟩ := exists_minimal_surface M (fun v => A₃ v || A₄ v || A₀ v)
  obtain ⟨f₄, hf₄, e₄⟩ := exists_minimal_surface M (fun v => A₄ v || A₀ v || A₁ v)
  have hv : ∀ v, M.bdry v = true →
      f₀ v = (A₀ v || A₁ v || A₂ v) ∧ f₁ v = (A₁ v || A₂ v || A₃ v) ∧
      f₂ v = (A₂ v || A₃ v || A₄ v) ∧ f₃ v = (A₃ v || A₄ v || A₀ v) ∧
      f₄ v = (A₄ v || A₀ v || A₁ v) :=
    fun v hb => ⟨hf₀ v hb, hf₁ v hb, hf₂ v hb, hf₃ v hb, hf₄ v hb⟩
  have hrot : ∀ (a₀ a₁ a₂ a₃ a₄ : Bool), AtMostOneTrue a₀ a₁ a₂ a₃ a₄ →
      AtMostOneTrue a₁ a₂ a₃ a₄ a₀ := by
    intro a₀ a₁ a₂ a₃ a₄
    revert a₀ a₁ a₂ a₃ a₄
    decide
  have adm01 : Admissible M (fun v => A₀ v || A₁ v)
      (fun v => cyc (f₀ v) (f₁ v) (f₂ v) (f₃ v) (f₄ v)) := by
    intro v hb
    obtain ⟨p₀, p₁, p₂, p₃, p₄⟩ := hv v hb
    show cyc (f₀ v) (f₁ v) (f₂ v) (f₃ v) (f₄ v) = (A₀ v || A₁ v)
    rw [p₀, p₁, p₂, p₃, p₄]
    exact cyc_boundary (A₀ v) (A₁ v) (A₂ v) (A₃ v) (A₄ v) (hd v)
  have adm12 : Admissible M (fun v => A₁ v || A₂ v)
      (fun v => cyc (f₁ v) (f₂ v) (f₃ v) (f₄ v) (f₀ v)) := by
    intro v hb
    obtain ⟨p₀, p₁, p₂, p₃, p₄⟩ := hv v hb
    show cyc (f₁ v) (f₂ v) (f₃ v) (f₄ v) (f₀ v) = (A₁ v || A₂ v)
    rw [p₀, p₁, p₂, p₃, p₄]
    exact cyc_boundary (A₁ v) (A₂ v) (A₃ v) (A₄ v) (A₀ v) (hrot _ _ _ _ _ (hd v))
  have adm23 : Admissible M (fun v => A₂ v || A₃ v)
      (fun v => cyc (f₂ v) (f₃ v) (f₄ v) (f₀ v) (f₁ v)) := by
    intro v hb
    obtain ⟨p₀, p₁, p₂, p₃, p₄⟩ := hv v hb
    show cyc (f₂ v) (f₃ v) (f₄ v) (f₀ v) (f₁ v) = (A₂ v || A₃ v)
    rw [p₀, p₁, p₂, p₃, p₄]
    exact cyc_boundary (A₂ v) (A₃ v) (A₄ v) (A₀ v) (A₁ v)
      (hrot _ _ _ _ _ (hrot _ _ _ _ _ (hd v)))
  have adm34 : Admissible M (fun v => A₃ v || A₄ v)
      (fun v => cyc (f₃ v) (f₄ v) (f₀ v) (f₁ v) (f₂ v)) := by
    intro v hb
    obtain ⟨p₀, p₁, p₂, p₃, p₄⟩ := hv v hb
    show cyc (f₃ v) (f₄ v) (f₀ v) (f₁ v) (f₂ v) = (A₃ v || A₄ v)
    rw [p₀, p₁, p₂, p₃, p₄]
    exact cyc_boundary (A₃ v) (A₄ v) (A₀ v) (A₁ v) (A₂ v)
      (hrot _ _ _ _ _ (hrot _ _ _ _ _ (hrot _ _ _ _ _ (hd v))))
  have adm40 : Admissible M (fun v => A₄ v || A₀ v)
      (fun v => cyc (f₄ v) (f₀ v) (f₁ v) (f₂ v) (f₃ v)) := by
    intro v hb
    obtain ⟨p₀, p₁, p₂, p₃, p₄⟩ := hv v hb
    show cyc (f₄ v) (f₀ v) (f₁ v) (f₂ v) (f₃ v) = (A₄ v || A₀ v)
    rw [p₀, p₁, p₂, p₃, p₄]
    exact cyc_boundary (A₄ v) (A₀ v) (A₁ v) (A₂ v) (A₃ v)
      (hrot _ _ _ _ _ (hrot _ _ _ _ _ (hrot _ _ _ _ _ (hrot _ _ _ _ _ (hd v)))))
  have admAll : Admissible M (fun v => A₀ v || A₁ v || A₂ v || A₃ v || A₄ v)
      (fun v => f₀ v || f₁ v || f₂ v || f₃ v || f₄ v) := by
    intro v hb
    obtain ⟨p₀, p₁, p₂, p₃, p₄⟩ := hv v hb
    show (f₀ v || f₁ v || f₂ v || f₃ v || f₄ v)
      = (A₀ v || A₁ v || A₂ v || A₃ v || A₄ v)
    rw [p₀, p₁, p₂, p₃, p₄]
    cases A₀ v <;> cases A₁ v <;> cases A₂ v <;> cases A₃ v <;> cases A₄ v <;> rfl
  have k01 := entropy_le_of_admissible adm01
  have k12 := entropy_le_of_admissible adm12
  have k23 := entropy_le_of_admissible adm23
  have k34 := entropy_le_of_admissible adm34
  have k40 := entropy_le_of_admissible adm40
  have kAll := entropy_le_of_admissible admAll
  have key := cutWeight_cyclic5 M.toBulkGraph f₀ f₁ f₂ f₃ f₄
  rw [e₀, e₁, e₂, e₃, e₄]
  linarith

end EmergentGeometry