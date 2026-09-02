import Probability.NET59NonIdentifiability
import Probability.NET59DobrushinMasking

/-!
# NET-59, round 3: when *is* a solo ablation informative?

`Probability.NET59DobrushinMasking` shows that downstream contraction hides
damage exponentially.  The natural converse question is: which stacks does a
solo ablation measure faithfully?  The answer proved here is *lossless* ones.

A **permutation channel** `permK e` deterministically relabels the state by a
bijection `e`.  Such a channel is exactly a lossless layer: it preserves total
variation on the nose (`tv_push_permK`), so its Dobrushin coefficient is `1`, the
worst possible.

* `tv_chain_permK` — a stack of permutation layers is a total-variation isometry.
* `solo_eq_point_of_lossless` — **identifiability**: if every layer after `j` is
  lossless, the solo cost of layer `j` equals its point cost exactly.  No
  masking occurs, and the NET-59 measurement is faithful at layer `j`.
* `solo_le_of_suffix_contraction` — the sharp form of the masking theorem: only
  the contraction coefficient of the *whole suffix* matters, not the individual
  layers.  `solo_le_pow_point` is the special case where the suffix is bounded
  layerwise.
* `witness_suffix_contracts` / `witness_masking_is_the_zero_endpoint` — the
  non-identifiability witness of `Probability.NET59NonIdentifiability` is
  exactly the `c = 0` endpoint of that bound, and the bound is attained with
  equality there.  Together with `solo_eq_point_of_lossless` (the `c = 1`
  endpoint, also attained with equality) this shows the entire range from
  "the solo profile measures everything" to "the solo profile measures nothing"
  is controlled by downstream contraction alone — with no reference whatsoever
  to which layer is important.
-/

namespace Catalog.Probability.NET59

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## 1. Lossless layers -/

/-- The deterministic channel that relabels the state by the bijection `e`. -/
def permK (e : α ≃ α) : Kern α α := fun a => dirac (e a)

theorem push_permK (e : α ≃ α) (μ : Dist α) (b : α) :
    (push (permK e) μ).p b = μ.p (e.symm b) := by
  simp only [push_apply, permK, dirac]
  rw [Finset.sum_eq_single (e.symm b)]
  · simp
  · intro a _ hne
    have hb : ¬ (b = e a) := by
      intro hb; exact hne (by rw [hb, Equiv.symm_apply_apply])
    simp [hb]
  · intro h; exact absurd (Finset.mem_univ _) h

/-- **A lossless layer is a total-variation isometry.** -/
theorem tv_push_permK (e : α ≃ α) (μ ν : Dist α) :
    tv (push (permK e) μ) (push (permK e) ν) = tv μ ν := by
  unfold tv
  congr 1
  have h : ∀ b : α, |(push (permK e) μ).p b - (push (permK e) ν).p b|
      = |μ.p (e.symm b) - ν.p (e.symm b)| := by
    intro b; rw [push_permK, push_permK]
  rw [Finset.sum_congr rfl fun b _ => h b]
  exact Fintype.sum_equiv e.symm _ _ fun b => rfl

/-- A stack of lossless layers is a total-variation isometry. -/
theorem tv_chain_permK :
    ∀ (L : List (α ≃ α)) (μ ν : Dist α),
      tv (chain (L.map permK) μ) (chain (L.map permK) ν) = tv μ ν := by
  intro L
  induction L with
  | nil => intro μ ν; simp
  | cons e L ih =>
      intro μ ν
      rw [List.map_cons, chain_cons, chain_cons, ih, tv_push_permK]

/-- Two distinct point masses are at maximal total variation distance. -/
theorem tv_dirac_ne (x y : α) (hxy : x ≠ y) : tv (dirac x) (dirac y) = 1 := by
  unfold tv dirac
  have hzero : ∀ z ∈ (univ : Finset α), z ∉ ({x, y} : Finset α) →
      |(if z = x then (1:ℚ) else 0) - (if z = y then (1:ℚ) else 0)| = 0 := by
    intro z _ hz
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hz
    rw [if_neg hz.1, if_neg hz.2]
    simp
  rw [← Finset.sum_subset (Finset.subset_univ ({x, y} : Finset α)) hzero,
    Finset.sum_pair hxy]
  rw [if_pos rfl, if_neg hxy, if_neg (Ne.symm hxy), if_pos rfl]
  norm_num

/-- A lossless layer has Dobrushin coefficient `1` whenever the relabelling
actually separates two states: no contraction at all is available. -/
theorem permK_dobrushin_one (e : α ≃ α) (a b : α) (hab : a ≠ b) :
    tv ((permK e) a) ((permK e) b) = 1 :=
  tv_dirac_ne _ _ (fun h => hab (e.injective h))

/-! ## 2. Identifiability at a lossless suffix -/

/-- **Identifiability.**  If every layer after `j` is lossless, the solo ablation
of layer `j` reports its point cost exactly: the NET-59 measurement is faithful
at that layer. -/
theorem solo_eq_point_of_lossless (F : List (Kern α α)) (j : ℕ) (f p : Kern α α)
    (hj : j < F.length) (hf : F[j] = f) (E : List (α ≃ α))
    (hdown : F.drop (j + 1) = E.map permK) (μ : Dist α) :
    tv (chain F μ) (chain (F.set j p) μ)
      = tv (push f (upstream F j μ)) (push p (upstream F j μ)) := by
  have hF : F = F.take j ++ f :: F.drop (j + 1) := by
    conv_lhs => rw [← List.set_getElem_self hj]
    rw [List.set_eq_take_cons_drop _ hj, hf]
  have hFset : F.set j p = F.take j ++ p :: F.drop (j + 1) :=
    List.set_eq_take_cons_drop _ hj
  have e1 : chain F μ = chain (F.drop (j + 1)) (push f (upstream F j μ)) := by
    conv_lhs => rw [hF]
    rw [chain_append, chain_cons, upstream]
  have e2 : chain (F.set j p) μ = chain (F.drop (j + 1)) (push p (upstream F j μ)) := by
    rw [hFset, chain_append, chain_cons, upstream]
  rw [e1, e2, hdown, tv_chain_permK]

/-! ## 3. The sharp masking bound, and its two endpoints -/

omit [DecidableEq α] in
/-- **Sharp masking.**  Only the contraction coefficient of the whole downstream
suffix matters.  `solo_le_pow_point` is the special case in which the suffix is
controlled layer by layer. -/
theorem solo_le_of_suffix_contraction {c : ℚ} (F : List (Kern α α)) (j : ℕ) (f p : Kern α α)
    (hj : j < F.length) (hf : F[j] = f)
    (hS : ∀ μ' ν' : Dist α,
      tv (chain (F.drop (j + 1)) μ') (chain (F.drop (j + 1)) ν') ≤ c * tv μ' ν')
    (μ : Dist α) :
    tv (chain F μ) (chain (F.set j p) μ)
      ≤ c * tv (push f (upstream F j μ)) (push p (upstream F j μ)) := by
  have hF : F = F.take j ++ f :: F.drop (j + 1) := by
    conv_lhs => rw [← List.set_getElem_self hj]
    rw [List.set_eq_take_cons_drop _ hj, hf]
  have hFset : F.set j p = F.take j ++ p :: F.drop (j + 1) :=
    List.set_eq_take_cons_drop _ hj
  have e1 : chain F μ = chain (F.drop (j + 1)) (push f (upstream F j μ)) := by
    conv_lhs => rw [hF]
    rw [chain_append, chain_cons, upstream]
  have e2 : chain (F.set j p) μ = chain (F.drop (j + 1)) (push p (upstream F j μ)) := by
    rw [hFset, chain_append, chain_cons, upstream]
  rw [e1, e2]
  exact hS _ _

omit [DecidableEq α] in
/-- A constant layer has Dobrushin coefficient `0`. -/
theorem constK_dobrushin_zero (c : Dist α) (a b : α) :
    tv ((constK c : Kern α α) a) ((constK c : Kern α α) b) = 0 := by
  simp [constK]

/-- The suffix of the non-identifiability witness after any transparent layer
still ends in the constant layer, so it collapses everything: its contraction
coefficient is `0`. -/
theorem witness_suffix_contracts (n j : ℕ) (hj : j < n) (μ ν : Dist (Fin 2)) :
    tv (chain ((fullStack n).drop (j + 1)) μ) (chain ((fullStack n).drop (j + 1)) ν)
      ≤ 0 * tv μ ν := by
  have hdrop : (fullStack n).drop (j + 1)
      = List.replicate (n - (j + 1)) idK ++ [constK d0] := by
    rw [fullStack, List.drop_append_of_le_length (by simpa using hj), List.drop_replicate]
  rw [hdrop, chain_snoc_constK, chain_snoc_constK, tv_self]
  simp

/-- **The witness is the `c = 0` endpoint.**  For the non-identifiability witness
the sharp masking bound holds with `c = 0`, and is attained with equality: the
solo cost is `0` while the point cost is the full `t`.  Together with
`solo_eq_point_of_lossless` (equality at `c = 1`) this brackets the whole range
of possible relations between the measured solo profile and the true per-layer
damage. -/
theorem witness_masking_is_the_zero_endpoint (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1)
    (j : ℕ) (hj : j < n) :
    tv (chain (fullStack n) d0)
        (chain ((fullStack n).set j (prunedLayer n t h0 h1 j)) d0)
      = 0 * tv (push idK (upstream (fullStack n) j d0))
          (push (prunedLayer n t h0 h1 j) (upstream (fullStack n) j d0)) ∧
    tv (push idK (upstream (fullStack n) j d0))
        (push (prunedLayer n t h0 h1 j) (upstream (fullStack n) j d0)) = t := by
  refine ⟨?_, pointCost_eq_target n t h0 h1 j hj⟩
  rw [soloCost_eq_zero n t h0 h1 j (by omega), zero_mul]

end Catalog.Probability.NET59