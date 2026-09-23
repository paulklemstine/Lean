/-
# Maximal non-winnable classes on complete graphs

The Baker–Norine dichotomy says a divisor `D` is non-winnable exactly when `D ≤ ν_t` for some
acyclic orientation divisor `ν_t`.  On the complete graph the divisors `ν_t` are indexed by
orderings of the vertices, and this file shows that *distinct orderings with the same minimum
give linearly inequivalent divisors*.  The proof runs through the theory of `q`-reduced
divisors: `ν_t` is exactly the `q`-reduced representative of its class when `q` is the
`t`-minimal vertex, and `q`-reduced representatives are unique.

Consequence: `K_{n+1}` carries at least `n!` pairwise inequivalent divisor classes of degree
`g - 1` and rank `-1`.  (Computationally, `n!` is the exact number.)
-/
import Combinatorics.TropicalRiemannRoch.CompleteGraph

namespace TropicalRR

open Finset

section TopReduced

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- On the complete graph, firing a set `S` containing `v` sends one chip from `v` to each of
the `|V| - |S|` vertices outside `S`. -/
lemma outdeg_top_of_mem {S : Finset V} {v : V} (hv : v ∈ S) :
    outdeg (⊤ : SimpleGraph V) S v = Fintype.card V - S.card := by
  have h : ((⊤ : SimpleGraph V).neighborFinset v) \ S = univ \ S := by
    ext w
    simp only [Finset.mem_sdiff, SimpleGraph.mem_neighborFinset, SimpleGraph.top_adj,
      Finset.mem_univ, true_and]
    exact ⟨fun h => h.2, fun h => ⟨fun hvw => h (hvw ▸ hv), h⟩⟩
  rw [outdeg, h, Finset.card_univ_diff]

/-- **`ν_t` is the `q`-reduced representative of its class on `K_n`.**  If `q` has the
smallest `t`-rank then `ν_t` is `q`-reduced: it is nonnegative away from `q` and no set of
vertices avoiding `q` can be fired legally. -/
theorem nu_top_qreduced {t : V → ℕ} (ht : Function.Injective t) {q : V}
    (hq : ∀ v, t q ≤ t v) : QReduced (⊤ : SimpleGraph V) q (nu (⊤ : SimpleGraph V) t) := by
  constructor
  · -- nonnegative away from `q`: every `v ≠ q` has `q` strictly below it
    intro v hv
    rw [nu_top]
    have hmem : q ∈ univ.filter (fun w => t w < t v) := by
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      rcases lt_or_eq_of_le (hq v) with h | h
      · exact h
      · exact absurd (ht h).symm hv
    have := Finset.card_pos.2 ⟨q, hmem⟩
    omega
  · -- no legal set-firing: use the `t`-minimal vertex of `S`
    intro S hS hqS
    obtain ⟨v, hvS, hvmin⟩ := Finset.exists_min_image S t hS
    refine ⟨v, hvS, ?_⟩
    rw [nu_top, outdeg_top_of_mem hvS]
    have hsub : univ.filter (fun w => t w < t v) ⊆ univ \ S := by
      intro w hw
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hw
      simp only [Finset.mem_sdiff, Finset.mem_univ, true_and]
      intro hwS
      have := hvmin w hwS
      omega
    have hcard := Finset.card_le_card hsub
    rw [Finset.card_univ_diff] at hcard
    have hSpos : 0 < S.card := Finset.card_pos.2 hS
    have hSle : S.card ≤ Fintype.card V := Finset.card_le_univ S
    omega

end TopReduced

section Perm

variable {m : ℕ}

/-- The maximal non-winnable divisor of `K_m` attached to the vertex ordering `σ`. -/
def nuPerm (σ : Equiv.Perm (Fin m)) : Divisor (Fin m) :=
  nu (⊤ : SimpleGraph (Fin m)) (fun v => (σ v : ℕ))

lemma nuPerm_rank_injective (σ : Equiv.Perm (Fin m)) :
    Function.Injective (fun v => ((σ v : ℕ))) := fun _ _ h => σ.injective (Fin.ext h)

/-- Explicitly, `ν_σ (v) = σ(v) - 1`. -/
lemma nuPerm_apply (σ : Equiv.Perm (Fin m)) (v : Fin m) : nuPerm σ v = (σ v : ℤ) - 1 := by
  rw [nuPerm, nu_top]
  congr 1
  have h : (univ.filter (fun w => (σ w : ℕ) < (σ v : ℕ))) = (Finset.Iio (σ v)).image σ.symm := by
    ext w
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image, Finset.mem_Iio]
    constructor
    · intro h
      exact ⟨σ w, Fin.lt_def.2 h, σ.symm_apply_apply w⟩
    · rintro ⟨x, hx, rfl⟩
      rw [Equiv.apply_symm_apply]
      exact Fin.lt_def.1 hx
  rw [h, Finset.card_image_of_injective _ σ.symm.injective, Fin.card_Iio]

variable [NeZero m]

omit [NeZero m] in
/-- Its degree is `g - 1`. -/
theorem degD_nuPerm (σ : Equiv.Perm (Fin m)) :
    degD (nuPerm σ) = genus (⊤ : SimpleGraph (Fin m)) - 1 :=
  degD_nu _ _ (nuPerm_rank_injective σ)

/-- Its Baker–Norine rank is `-1`: it is a maximal non-winnable divisor. -/
theorem rank_nuPerm (σ : Equiv.Perm (Fin m)) :
    rank (⊤ : SimpleGraph (Fin m)) (nuPerm σ) = -1 := by
  rw [rank_eq_neg_one_iff]
  exact nu_not_winnable _ _

/-- If `σ` fixes the base vertex `0` then `ν_σ` is `0`-reduced. -/
theorem nuPerm_qreduced {σ : Equiv.Perm (Fin m)} (h0 : σ 0 = 0) :
    QReduced (⊤ : SimpleGraph (Fin m)) 0 (nuPerm σ) := by
  refine nu_top_qreduced (nuPerm_rank_injective σ) (fun v => ?_)
  simp only [h0, Fin.val_zero]
  exact Nat.zero_le _

/-- **Distinct orderings give distinct classes.**  Two vertex orderings of `K_m` that both fix
the base vertex and yield linearly equivalent orientation divisors are equal.  This is proved
by identifying `ν_σ` as the (unique) `0`-reduced representative of its class. -/
theorem nuPerm_eq_of_linEquiv {σ τ : Equiv.Perm (Fin m)} (hσ : σ 0 = 0) (hτ : τ 0 = 0)
    (h : LinEquiv (⊤ : SimpleGraph (Fin m)) (nuPerm σ) (nuPerm τ)) : σ = τ := by
  have heq : nuPerm σ = nuPerm τ :=
    qreduced_unique _ h (nuPerm_qreduced hσ) (nuPerm_qreduced hτ)
  refine Equiv.ext fun v => Fin.ext ?_
  have := congrFun heq v
  rw [nuPerm_apply, nuPerm_apply] at this
  omega

end Perm

section Counting

variable {n : ℕ}

/-- The `n!` maximal non-winnable divisors of `K_{n+1}`, indexed by the orderings of the
`n` non-base vertices. -/
def nuOrd (p : Equiv.Perm (Fin n)) : Divisor (Fin (n + 1)) :=
  nuPerm (Equiv.Perm.decomposeFin.symm (0, p))

lemma nuOrd_fixes_zero (p : Equiv.Perm (Fin n)) :
    (Equiv.Perm.decomposeFin.symm (0, p) : Equiv.Perm (Fin (n + 1))) 0 = 0 :=
  Equiv.Perm.decomposeFin_symm_apply_zero 0 p

/-- Distinct orderings of the non-base vertices give linearly inequivalent divisors. -/
theorem nuOrd_linEquiv_iff {p q : Equiv.Perm (Fin n)}
    (h : LinEquiv (⊤ : SimpleGraph (Fin (n + 1))) (nuOrd p) (nuOrd q)) : p = q := by
  have := nuPerm_eq_of_linEquiv (nuOrd_fixes_zero p) (nuOrd_fixes_zero q) h
  have h2 : ((0 : Fin (n + 1)), p) = ((0 : Fin (n + 1)), q) :=
    Equiv.Perm.decomposeFin.symm.injective this
  exact (Prod.mk.injEq _ _ _ _ ▸ h2).2

theorem nuOrd_injective : Function.Injective (nuOrd (n := n)) := by
  intro p _ h
  exact nuOrd_linEquiv_iff (h ▸ LinEquiv.refl _ (nuOrd p))

/-- **At least `n!` maximal non-winnable classes on `K_{n+1}`.**  There is a family of `n!`
divisors on the complete graph `K_{n+1}`, all of degree `g - 1` and rank `-1`, that are
pairwise linearly inequivalent.  Computation shows this count is exact. -/
theorem card_maximal_nonwinnable_completeGraph (n : ℕ) :
    ∃ S : Finset (Divisor (Fin (n + 1))), S.card = Nat.factorial n ∧
      (∀ D ∈ S, degD D = genus (⊤ : SimpleGraph (Fin (n + 1))) - 1) ∧
      (∀ D ∈ S, rank (⊤ : SimpleGraph (Fin (n + 1))) D = -1) ∧
      (∀ D ∈ S, ∀ E ∈ S, LinEquiv (⊤ : SimpleGraph (Fin (n + 1))) D E → D = E) := by
  classical
  refine ⟨Finset.image (nuOrd (n := n)) univ, ?_, ?_, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ nuOrd_injective, Finset.card_univ, Fintype.card_perm,
      Fintype.card_fin]
  · rintro D hD
    obtain ⟨p, -, rfl⟩ := Finset.mem_image.1 hD
    exact degD_nuPerm _
  · rintro D hD
    obtain ⟨p, -, rfl⟩ := Finset.mem_image.1 hD
    exact rank_nuPerm _
  · rintro D hD E hE h
    obtain ⟨p, -, rfl⟩ := Finset.mem_image.1 hD
    obtain ⟨q, -, rfl⟩ := Finset.mem_image.1 hE
    rw [nuOrd_linEquiv_iff h]

end Counting

/-! ### Top-degree rigidity: the maximal non-winnable divisors are exactly the `ν_t` -/

section Rigidity

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] [Nonempty V] in
/-- Pointwise domination together with equal degrees forces equality of divisors. -/
lemma eq_of_le_of_degD_eq {D E : Divisor V} (hle : ∀ v, D v ≤ E v) (h : degD D = degD E) :
    D = E := by
  funext v
  by_contra hne
  have hlt : D v < E v := lt_of_le_of_ne (hle v) hne
  have : degD D < degD E :=
    Finset.sum_lt_sum (fun i _ => hle i) ⟨v, Finset.mem_univ v, hlt⟩
  omega

omit [Nonempty V] in
/-- **Top-degree rigidity.**  A `q`-reduced, non-winnable divisor of degree `g - 1` *is* an
acyclic-orientation divisor `ν_t` — not merely dominated by one.  This sharpens
`exists_nu_dominating` in the top degree. -/
theorem eq_nu_of_qreduced_of_degD {q : V} {D : Divisor V} (hD : QReduced G q D)
    (hnw : ¬ Winnable G D) (hdeg : degD D = genus G - 1) :
    ∃ t : V → ℕ, Function.Injective t ∧ D = nu G t := by
  have hq : D q ≤ -1 := by
    have h1 : ¬ (0 ≤ D q) := fun hge => hnw ((winnable_iff_qreduced G hD).2 hge)
    omega
  obtain ⟨t, htinj, hdom⟩ := exists_nu_dominating G hD.2 hq
  refine ⟨t, htinj, eq_of_le_of_degD_eq hdom ?_⟩
  rw [hdeg, degD_nu G t htinj]

omit [Nonempty V] in
/-- Every non-winnable divisor of degree `g - 1` on a connected graph is linearly equivalent
to an acyclic-orientation divisor. -/
theorem linEquiv_nu_of_degD (hc : G.Connected) {q : V} {D : Divisor V}
    (hnw : ¬ Winnable G D) (hdeg : degD D = genus G - 1) :
    ∃ t : V → ℕ, Function.Injective t ∧ LinEquiv G D (nu G t) := by
  obtain ⟨f, hred⟩ := exists_qreduced G hc D q
  have hlin : LinEquiv G D (D - lap G f) := ⟨f, rfl⟩
  have hnw' : ¬ Winnable G (D - lap G f) := fun hw => hnw (Winnable.of_linEquiv G hlin hw)
  have hdeg' : degD (D - lap G f) = genus G - 1 := by
    rw [LinEquiv.degD_eq G hlin]; exact hdeg
  obtain ⟨t, htinj, ht⟩ := eq_nu_of_qreduced_of_degD G hred hnw' hdeg'
  exact ⟨t, htinj, ht ▸ hlin⟩

end Rigidity

/-! ### The count on `K_n` is exact -/

section Exact

open Finset

variable {m : ℕ}

/-- The rank permutation of an injective vertex ranking of `K_m`: `v` is sent to the number of
vertices strictly below it. -/
noncomputable def rankPerm {t : Fin m → ℕ} (ht : Function.Injective t) :
    Equiv.Perm (Fin m) := by
  refine Equiv.ofBijective (fun v => ⟨(univ.filter (fun w => t w < t v)).card, ?_⟩)
    (Finite.injective_iff_bijective.1 ?_)
  · have hsub : (univ.filter (fun w : Fin m => t w < t v)) ⊆ univ.erase v := by
      intro w hw
      simp only [mem_filter, mem_univ, true_and] at hw
      refine Finset.mem_erase.2 ⟨?_, Finset.mem_univ w⟩
      rintro rfl; omega
    have hle := Finset.card_le_card hsub
    rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ, Fintype.card_fin] at hle
    have hm : 0 < m := v.pos
    omega
  · intro a b hab
    simp only [Fin.mk.injEq] at hab
    by_contra hne
    have key : ∀ x y : Fin m, t x < t y →
        (univ.filter (fun w => t w < t x)).card < (univ.filter (fun w => t w < t y)).card := by
      intro x y hxy
      refine Finset.card_lt_card ⟨fun w hw => ?_, fun hc => ?_⟩
      · simp only [mem_filter, mem_univ, true_and] at hw ⊢
        omega
      · have hx : x ∈ univ.filter (fun w => t w < t x) := hc (by simp [hxy])
        simp only [mem_filter, mem_univ, true_and] at hx
        omega
    rcases lt_trichotomy (t a) (t b) with h | h | h
    · exact absurd hab (Nat.ne_of_lt (key a b h))
    · exact hne (ht h)
    · exact absurd hab.symm (Nat.ne_of_lt (key b a h))

lemma rankPerm_val {t : Fin m → ℕ} (ht : Function.Injective t) (v : Fin m) :
    ((rankPerm ht v : Fin m) : ℕ) = (univ.filter (fun w => t w < t v)).card := rfl

variable [NeZero m]

omit [NeZero m] in
/-- Every acyclic-orientation divisor on `K_m` comes from a permutation. -/
lemma nuPerm_rankPerm {t : Fin m → ℕ} (ht : Function.Injective t) :
    nuPerm (rankPerm ht) = nu (⊤ : SimpleGraph (Fin m)) t := by
  funext v
  rw [nuPerm_apply, nu_top, rankPerm_val ht v]

end Exact

section ExactCount

variable {n : ℕ}

/-- **The `n!` divisors are exactly the `0`-reduced maximal non-winnable divisors of degree
`g - 1` on `K_{n+1}`.**  Combined with `card_maximal_nonwinnable_completeGraph` this determines
the count exactly: there are precisely `n!` such divisors, one for each ordering of the
non-base vertices. -/
theorem qreduced_nonwinnable_iff_nuOrd (D : Divisor (Fin (n + 1))) :
    (QReduced (⊤ : SimpleGraph (Fin (n + 1))) 0 D ∧
        ¬ Winnable (⊤ : SimpleGraph (Fin (n + 1))) D ∧
        degD D = genus (⊤ : SimpleGraph (Fin (n + 1))) - 1)
      ↔ ∃ p : Equiv.Perm (Fin n), nuOrd p = D := by
  constructor
  · rintro ⟨hred, hnw, hdeg⟩
    obtain ⟨t, ht, hDt⟩ :=
      eq_nu_of_qreduced_of_degD (⊤ : SimpleGraph (Fin (n + 1))) hred hnw hdeg
    set sig := rankPerm ht with hsig
    have hD : nuPerm sig = D := by rw [hsig, nuPerm_rankPerm ht, ← hDt]
    -- the base vertex has to be the `t`-minimal one
    have hq : D 0 ≤ -1 := by
      have h1 : ¬ (0 ≤ D 0) := fun hge =>
        hnw ((winnable_iff_qreduced (⊤ : SimpleGraph (Fin (n + 1))) hred).2 hge)
      omega
    have hzero : sig 0 = 0 := by
      have h2 := congrFun hD 0
      rw [nuPerm_apply] at h2
      have hcast : ((sig 0 : Fin (n + 1)) : ℤ) = (((sig 0 : Fin (n + 1)) : ℕ) : ℤ) := rfl
      rw [hcast] at h2
      have hz : ((sig 0 : Fin (n + 1)) : ℕ) = 0 := by omega
      exact Fin.ext (by simpa using hz)
    -- decompose `sig` as a permutation of the non-base vertices
    refine ⟨(Equiv.Perm.decomposeFin sig).2, ?_⟩
    have hfst : (Equiv.Perm.decomposeFin sig).1 = 0 := by
      have hs : Equiv.Perm.decomposeFin.symm (Equiv.Perm.decomposeFin sig) = sig :=
        Equiv.symm_apply_apply _ _
      calc (Equiv.Perm.decomposeFin sig).1
          = (Equiv.Perm.decomposeFin.symm
              ((Equiv.Perm.decomposeFin sig).1, (Equiv.Perm.decomposeFin sig).2)) 0 :=
            (Equiv.Perm.decomposeFin_symm_apply_zero _ _).symm
        _ = sig 0 := by rw [Prod.mk.eta, hs]
        _ = 0 := hzero
    have hpair : ((0 : Fin (n + 1)), (Equiv.Perm.decomposeFin sig).2)
        = Equiv.Perm.decomposeFin sig := by
      rw [← hfst, Prod.mk.eta]
    rw [nuOrd, hpair, Equiv.symm_apply_apply, hD]
  · rintro ⟨p, rfl⟩
    refine ⟨nuPerm_qreduced (nuOrd_fixes_zero p), ?_, degD_nuPerm _⟩
    rw [← rank_eq_neg_one_iff]
    exact rank_nuPerm _

/-- **Exact count.**  The complete graph `K_{n+1}` has exactly `n !` maximal non-winnable
divisors in `0`-reduced form, i.e. exactly `n !` divisor classes of degree `g - 1` and
rank `-1`.  This upgrades the lower bound of `card_maximal_nonwinnable_completeGraph` to an
equality. -/
theorem ncard_maximal_nonwinnable_completeGraph (n : ℕ) :
    Set.ncard {D : Divisor (Fin (n + 1)) |
        QReduced (⊤ : SimpleGraph (Fin (n + 1))) 0 D ∧
        ¬ Winnable (⊤ : SimpleGraph (Fin (n + 1))) D ∧
        degD D = genus (⊤ : SimpleGraph (Fin (n + 1))) - 1} = Nat.factorial n := by
  classical
  have hset : {D : Divisor (Fin (n + 1)) |
      QReduced (⊤ : SimpleGraph (Fin (n + 1))) 0 D ∧
      ¬ Winnable (⊤ : SimpleGraph (Fin (n + 1))) D ∧
      degD D = genus (⊤ : SimpleGraph (Fin (n + 1))) - 1}
      = ↑(Finset.image (nuOrd (n := n)) Finset.univ) := by
    ext D
    simp only [Set.mem_setOf_eq, Finset.coe_image, Finset.coe_univ, Set.image_univ,
      Set.mem_range]
    exact qreduced_nonwinnable_iff_nuOrd D
  rw [hset, Set.ncard_coe_finset, Finset.card_image_of_injective _ nuOrd_injective,
    Finset.card_univ, Fintype.card_perm, Fintype.card_fin]

end ExactCount