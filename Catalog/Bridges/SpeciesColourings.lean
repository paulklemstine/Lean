/-
# The species of colourings: labelled and unlabelled counts

The species `colour k` sends a set `A` to the set `A → Fin k` of `k`-colourings.  It has
`kⁿ` labelled structures on `n` points, hence exponential generating series `exp(X)^k`,
and its *unlabelled* structures are exactly the multisets of size `n` over `Fin k`, hence
counted by `C(k+n-1, n)` (stars and bars).

Feeding this into the species form of Burnside's lemma gives

    ∑_{σ ∈ Sym(n)} |{ f : Fin n → Fin k | f ∘ σ⁻¹ = f }| = C(k+n-1, n) · n!,

the classical identity `∑_{σ} k^{c(σ)} = k(k+1)⋯(k+n-1)` in orbit-counting form.
-/
import Bridges.SpeciesAnalyticBridgeExtras
import Bridges.SpeciesUnlabelled

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

namespace Species

/-- The species of `k`-colourings. -/
def colour (k : ℕ) : Species where
  obj A := A → Fin k
  map e f := fun b => f (e.symm b)
  map_refl _ := rfl
  map_trans _ _ _ := rfl
  finite _ _ := inferInstance

@[simp] theorem colour_map_apply {k : ℕ} {A B : Type} (e : A ≃ B) (f : (colour k).obj A)
    (b : B) : (colour k).map e f b = f (e.symm b) := rfl

@[simp] theorem card_colour (k n : ℕ) : (colour k).card n = k ^ n := by
  simp [card, colour, Nat.card_eq_fintype_card]

/-- The exponential generating series of the species of `k`-colourings is `exp(X)^k`. -/
theorem egf_colour (k : ℕ) : (colour k).egf = (PowerSeries.exp ℚ) ^ k := by
  have h : (set.pow k).egf = (PowerSeries.exp ℚ) ^ k := by rw [egf_pow, egf_set]
  rw [← h]
  exact (egf_eq_iff _ _).2 fun n => by simp [card_set_pow]

/-! ## Unlabelled colourings are multisets -/

/-- The multiset of colours used by a colouring. -/
def colourMultiset {k n : ℕ} (f : Fin n → Fin k) : Sym (Fin k) n :=
  ⟨Multiset.map f Finset.univ.val, by simp⟩

theorem colourMultiset_smul {k n : ℕ} (σ : Equiv.Perm (Fin n)) (f : (colour k).obj (Fin n)) :
    colourMultiset ((colour k).map σ f) = colourMultiset f := by
  refine Subtype.ext ?_
  show Multiset.map (fun b => f (σ.symm b)) Finset.univ.val = Multiset.map f Finset.univ.val
  rw [show (fun b => f (σ.symm b)) = f ∘ σ.symm from rfl, ← Multiset.map_map]
  congr 1
  have : (Finset.univ.map σ.symm.toEmbedding) = Finset.univ := Finset.map_univ_equiv _
  calc Multiset.map σ.symm Finset.univ.val
      = (Finset.univ.map σ.symm.toEmbedding).val := rfl
    _ = Finset.univ.val := by rw [this]

/-- Two colourings using the same multiset of colours differ by a permutation of the
underlying set. -/
theorem exists_perm_of_colourMultiset_eq {k n : ℕ} (f g : Fin n → Fin k)
    (h : colourMultiset f = colourMultiset g) :
    ∃ σ : Equiv.Perm (Fin n), (colour k).map σ f = g := by
  classical
  have hcount : ∀ c : Fin k,
      Fintype.card {a : Fin n // f a = c} = Fintype.card {a : Fin n // g a = c} := by
    intro c
    have h' : Multiset.count c (Multiset.map f Finset.univ.val)
        = Multiset.count c (Multiset.map g Finset.univ.val) := by
      rw [show Multiset.map f Finset.univ.val = (colourMultiset f : Sym (Fin k) n).1 from rfl,
        show Multiset.map g Finset.univ.val = (colourMultiset g : Sym (Fin k) n).1 from rfl, h]
    rw [Multiset.count_map, Multiset.count_map] at h'
    rw [Fintype.card_subtype, Fintype.card_subtype]
    have e1 : Multiset.filter (fun a => c = f a) Finset.univ.val
        = (Finset.univ.filter fun a => f a = c).val := by
      rw [Finset.filter_val]
      congr 1
      funext a
      simp [eq_comm]
    have e2 : Multiset.filter (fun a => c = g a) Finset.univ.val
        = (Finset.univ.filter fun a => g a = c).val := by
      rw [Finset.filter_val]
      congr 1
      funext a
      simp [eq_comm]
    rw [e1, e2] at h'
    exact h'
  have e : ∀ c : Fin k, {a : Fin n // g a = c} ≃ {a : Fin n // f a = c} :=
    fun c => Fintype.equivOfCardEq (hcount c).symm
  set σ₀ := (Equiv.sigmaFiberEquiv g).symm.trans
    ((Equiv.sigmaCongrRight e).trans (Equiv.sigmaFiberEquiv f)) with hσ₀
  refine ⟨σ₀.symm, ?_⟩
  funext b
  show f (σ₀ b) = g b
  exact (e (g b) ⟨b, rfl⟩).2

/-- Unlabelled `k`-colourings of an `n`-set are the same thing as multisets of size `n`
over `Fin k`. -/
theorem unlabelled_colour (k n : ℕ) :
    (colour k).unlabelled n = Nat.card (Sym (Fin k) n) := by
  classical
  letI : Setoid ((colour k).obj (Fin n)) :=
    MulAction.orbitRel (Equiv.Perm (Fin n)) ((colour k).obj (Fin n))
  have hwd : ∀ a b : (colour k).obj (Fin n),
      a ≈ b → colourMultiset a = colourMultiset b := by
    rintro a b ⟨σ, hσ⟩
    have hσ' : (colour k).map σ b = a := hσ
    rw [← hσ', colourMultiset_smul]
  refine Nat.card_eq_of_bijective (Quotient.lift colourMultiset hwd) ⟨?_, ?_⟩
  · refine fun x y => Quotient.inductionOn₂ x y ?_
    intro a b hab
    obtain ⟨σ, hσ⟩ := exists_perm_of_colourMultiset_eq a b hab
    refine Quotient.sound ⟨σ⁻¹, ?_⟩
    show (colour k).map σ⁻¹ b = a
    rw [← hσ, (colour k).map_trans,
      show (σ : Fin n ≃ Fin n).trans (σ⁻¹ : Fin n ≃ Fin n) = Equiv.refl (Fin n) from
        Equiv.self_trans_symm σ, (colour k).map_refl]
  · intro s
    obtain ⟨l, hl⟩ := Quotient.exists_rep s.1
    have hlen : l.length = n := by rw [← s.2, ← hl]; rfl
    subst hlen
    refine ⟨Quotient.mk _ (fun i => l.get i), ?_⟩
    refine Subtype.ext ?_
    show Multiset.map (fun i => l.get i) Finset.univ.val = s.1
    rw [← hl, Finset.val_univ_fin]
    show (↑(List.map (fun i => l.get i) (List.finRange l.length)) : Multiset (Fin k)) = ↑l
    rw [← List.ofFn_eq_map, List.ofFn_get]

/-- **Stars and bars for species**: the number of unlabelled `k`-colourings of an
`n`-element set is `C(k+n-1, n)`. -/
theorem unlabelled_colour_eq_choose (k n : ℕ) :
    (colour k).unlabelled n = (k + n - 1).choose n := by
  classical
  rw [unlabelled_colour, Nat.card_eq_fintype_card, Sym.card_sym_eq_choose]
  simp

/-- **Burnside for colourings.**  Summing the number of colourings fixed by each
permutation gives `n!` times the number of multisets of colours. -/
theorem burnside_colour (k n : ℕ) :
    ∑ σ : Equiv.Perm (Fin n), Nat.card {f : Fin n → Fin k // ∀ a, f (σ.symm a) = f a}
      = (k + n - 1).choose n * n.factorial := by
  rw [← unlabelled_colour_eq_choose, ← burnside]
  refine Finset.sum_congr rfl fun σ _ => ?_
  refine Nat.card_congr (Equiv.subtypeEquivRight fun f => ?_)
  constructor
  · intro h
    funext a
    exact h a
  · intro h a
    exact congrFun h a


/-! ## The type generating series of the colouring species -/

/-- The series `∑ₙ C(k+n-1, n) Xⁿ`, i.e. the type generating series of `colour k`. -/
def multichooseSeries (k : ℕ) : ℚ⟦X⟧ :=
  PowerSeries.mk fun n => ((k + n - 1).choose n : ℚ)

theorem tgf_colour_eq (k : ℕ) : (colour k).tgf = multichooseSeries k := by
  ext n
  rw [coeff_tgf, unlabelled_colour_eq_choose, multichooseSeries, PowerSeries.coeff_mk]

theorem multichooseSeries_zero : multichooseSeries 0 = 1 := by
  ext n
  rw [multichooseSeries, PowerSeries.coeff_mk]
  match n with
  | 0 => simp
  | (n + 1) =>
      have hlt : 0 + (n + 1) - 1 < n + 1 := by omega
      rw [Nat.choose_eq_zero_of_lt hlt]
      simp

theorem multichooseSeries_succ (k : ℕ) :
    multichooseSeries (k + 1) * (1 - PowerSeries.X) = multichooseSeries k := by
  ext n
  rw [mul_sub, map_sub, mul_one]
  match n with
  | 0 =>
      simp only [multichooseSeries, PowerSeries.coeff_mk]
      simp
  | (n + 1) =>
      rw [PowerSeries.coeff_succ_mul_X]
      simp only [multichooseSeries, PowerSeries.coeff_mk]
      have hp : (k + 1 + (n + 1) - 1).choose (n + 1)
          = (k + n).choose n + (k + n).choose (n + 1) := by
        have : k + 1 + (n + 1) - 1 = (k + n) + 1 := by omega
        rw [this, Nat.choose_succ_succ (k + n) n]
      have h2 : k + (n + 1) - 1 = k + n := by omega
      have h3 : k + 1 + n - 1 = k + n := by omega
      rw [hp, h2, h3]
      push_cast
      ring

/-- **The type generating series of the species of `k`-colourings is `1/(1-X)^k`.**
The same functor has exponential generating series `exp(X)^k` (`egf_colour`). -/
theorem tgf_colour (k : ℕ) : (colour k).tgf * (1 - PowerSeries.X) ^ k = 1 := by
  rw [tgf_colour_eq]
  induction k with
  | zero => simpa using multichooseSeries_zero
  | succ k ih =>
      calc multichooseSeries (k + 1) * (1 - PowerSeries.X) ^ (k + 1)
          = (multichooseSeries (k + 1) * (1 - PowerSeries.X))
              * (1 - PowerSeries.X) ^ k := by ring
        _ = multichooseSeries k * (1 - PowerSeries.X) ^ k := by rw [multichooseSeries_succ]
        _ = 1 := ih

end Species

end SpeciesEGF