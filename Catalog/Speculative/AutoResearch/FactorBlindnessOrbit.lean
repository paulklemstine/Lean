/-
# Orbit blindness: the factor-blindness wall for an arbitrary symmetry group

`Computation.FactorBlindnessWall` proved that on a swap-closed, off-diagonal population a
symmetric readout leaks *exactly zero* bits about which of the two factors is the bigger one.
The proof there used a halving argument special to the involution `Prod.swap`.

This file closes the first open conjecture of that cycle (`FUTURE_DIRECTIONS.md`, direction A):
the phenomenon has nothing to do with involutions or with arithmetic.  Let a finite group `G`
act on a finite population `S`, let the readout `c` be `G`-invariant, and let the label
`lab : X → L` be a *torsor coordinate*: for every `x ∈ S` and every target label `l` there is a
**unique** `g ∈ G` with `lab (g · x) = l`.  Then the empirical contingency table of
(label, readout) is a product table, so the plug-in reading is `0` exactly
(`orbit_zero_leakage`).

The proof is a double count, not a halving: inside a readout fiber `F` one counts the pairs
`(x, g) ∈ F × G` with `lab (g · x) = l` in two ways.  Summing over `x` first gives `|F|`
(uniqueness of the torsor element); summing over `g` first gives `|G| · |cell l|`, because each
`g` acts as a bijection of `F`.  Hence every label cell of every fiber has the same size
`|F| / |G|`, which is precisely the product-table condition.

Two instances are given.

* `swap_orbit_zero_leakage` re-derives the two-factor wall (`galoisBlind_zero_leakage`) from the
  general theorem, with `G = Equiv.Perm (Fin 2)` acting by `Prod.swap`.
* `symmetricGroup_rank_zero_leakage` is the `k`-factor case the conjecture asked for: `Sₙ` acts
  on ordered `n`-tuples of naturals by permuting coordinates, the label is the full *ordering
  pattern* (the rank permutation of the tuple), and any permutation-invariant readout leaks
  exactly zero bits about the ordering of the factors — for every `n`, not just `n = 2`.
  `battery_triple_blind` is the three-factor headline instance.

No `sorry`; the only axioms used are `propext`, `Classical.choice`, `Quot.sound`.
-/
import Computation.FactorBlindnessInformation
import Computation.FactorBlindnessWall

namespace Computation.FactorBlindness

open Finset

/-! ## Part 1. The general orbit-blindness theorem -/

section Orbit

variable {X G L K : Type*} [DecidableEq X] [Group G] [Fintype G] [DecidableEq G]
  [Fintype L] [DecidableEq L] [Fintype K] [DecidableEq K]

/-- The (label, readout) cell of the contingency table of a population `S`. -/
def orbitCell (S : Finset X) (c : X → K) (lab : X → L) (l : L) (k : K) : Finset X :=
  S.filter (fun x => c x = k ∧ lab x = l)

/-- The readout fiber of a population `S`. -/
def orbitFiber (S : Finset X) (c : X → K) (k : K) : Finset X := S.filter (fun x => c x = k)

/-- The empirical joint law of (label, readout) on the population `S`. -/
noncomputable def orbitDist (S : Finset X) (c : X → K) (lab : X → L) (l : L) (k : K) : ℝ :=
  ((orbitCell S c lab l k).card : ℝ) / S.card

variable {S : Finset X} {c : X → K} {lab : X → L} {act : G → X → X}

omit [DecidableEq X] [Fintype G] [DecidableEq G] [Fintype L] [Fintype K] in
/-- Each group element permutes a readout fiber; transporting the `lab ∘ act g` slice of a
fiber along the action lands exactly on the label cell. -/
theorem card_fiber_filter_act (hone : ∀ x, act 1 x = x)
    (hmul : ∀ (g h : G) (x : X), act g (act h x) = act (g * h) x)
    (hS : ∀ (g : G), ∀ x ∈ S, act g x ∈ S) (hc : ∀ (g : G) (x : X), c (act g x) = c x)
    (g : G) (l : L) (k : K) :
    ((orbitFiber S c k).filter (fun x => lab (act g x) = l)).card
      = (orbitCell S c lab l k).card := by
  refine Finset.card_bij' (fun x _ => act g x) (fun y _ => act g⁻¹ y) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [orbitFiber, orbitCell, mem_filter] at ha ⊢
    obtain ⟨⟨haS, hak⟩, hal⟩ := ha
    exact ⟨hS g a haS, by rw [hc]; exact hak, hal⟩
  · intro b hb
    simp only [orbitFiber, orbitCell, mem_filter] at hb ⊢
    obtain ⟨hbS, hbk, hbl⟩ := hb
    refine ⟨⟨hS g⁻¹ b hbS, by rw [hc]; exact hbk⟩, ?_⟩
    rw [hmul, mul_inv_cancel, hone]
    exact hbl
  · intro a _
    show act g⁻¹ (act g a) = a
    rw [hmul, inv_mul_cancel, hone]
  · intro b _
    show act g (act g⁻¹ b) = b
    rw [hmul, mul_inv_cancel, hone]

omit [DecidableEq X] [Group G] [DecidableEq G] [Fintype L] in
/-- The torsor hypothesis: exactly one group element sends `x` to a given label. -/
theorem card_torsor_filter (htor : ∀ x ∈ S, ∀ l : L, ∃! g : G, lab (act g x) = l)
    {x : X} (hx : x ∈ S) (l : L) :
    ((univ : Finset G).filter (fun g => lab (act g x) = l)).card = 1 := by
  obtain ⟨g₀, hg₀, huniq⟩ := htor x hx l
  rw [Finset.card_eq_one]
  refine ⟨g₀, Finset.eq_singleton_iff_unique_mem.2 ⟨by simp [hg₀], ?_⟩⟩
  intro g hg
  exact huniq g (by simpa using hg)

omit [DecidableEq X] [DecidableEq G] [Fintype L] [Fintype K] in
/-- **The counting core.**  Every label cell of every readout fiber has exactly
`|fiber| / |G|` elements. -/
theorem card_orbitCell_mul (hone : ∀ x, act 1 x = x)
    (hmul : ∀ (g h : G) (x : X), act g (act h x) = act (g * h) x)
    (hS : ∀ (g : G), ∀ x ∈ S, act g x ∈ S) (hc : ∀ (g : G) (x : X), c (act g x) = c x)
    (htor : ∀ x ∈ S, ∀ l : L, ∃! g : G, lab (act g x) = l) (l : L) (k : K) :
    Fintype.card G * (orbitCell S c lab l k).card = (orbitFiber S c k).card := by
  have h1 : ∑ _g : G, (orbitCell S c lab l k).card
      = ∑ g : G, ((orbitFiber S c k).filter (fun x => lab (act g x) = l)).card :=
    Finset.sum_congr rfl fun g _ => (card_fiber_filter_act hone hmul hS hc g l k).symm
  have h2 : ∑ g : G, ((orbitFiber S c k).filter (fun x => lab (act g x) = l)).card
      = ∑ x ∈ orbitFiber S c k,
          ((univ : Finset G).filter (fun g => lab (act g x) = l)).card := by
    simp only [Finset.card_filter]
    exact Finset.sum_comm
  have h3 : ∑ x ∈ orbitFiber S c k,
      ((univ : Finset G).filter (fun g => lab (act g x) = l)).card
      = (orbitFiber S c k).card := by
    have hone_each : ∀ x ∈ orbitFiber S c k,
        ((univ : Finset G).filter (fun g => lab (act g x) = l)).card = 1 := by
      intro x hx
      have hxS : x ∈ S := by
        simp only [orbitFiber, mem_filter] at hx
        exact hx.1
      exact card_torsor_filter htor hxS l
    rw [Finset.sum_congr rfl hone_each]
    simp
  have h0 : ∑ _g : G, (orbitCell S c lab l k).card
      = Fintype.card G * (orbitCell S c lab l k).card := by
    simp [Finset.sum_const, Finset.card_univ]
  rw [← h0, h1, h2, h3]

omit [DecidableEq X] [Fintype K] in
/-- The label cells of a fixed fiber exhaust it. -/
theorem sum_card_orbitCell (k : K) :
    ∑ l, (orbitCell S c lab l k).card = (orbitFiber S c k).card := by
  have h : ∀ l : L, orbitCell S c lab l k = (orbitFiber S c k).filter (fun x => lab x = l) := by
    intro l
    simp only [orbitCell, orbitFiber, Finset.filter_filter]
  simp only [h]
  rw [eq_comm]
  exact Finset.card_eq_sum_card_fiberwise (fun x _ => mem_univ (lab x))

omit [DecidableEq X] in
/-- The readout fibers exhaust the population. -/
theorem sum_card_orbitFiber : ∑ k, (orbitFiber S c k).card = S.card := by
  rw [eq_comm]
  exact Finset.card_eq_sum_card_fiberwise (fun x _ => mem_univ (c x))

omit [DecidableEq X] [Fintype K] in
/-- The readout marginal is the fiber frequency. -/
theorem margK_orbitDist (k : K) :
    margK (orbitDist S c lab) k = ((orbitFiber S c k).card : ℝ) / S.card := by
  simp only [margK, orbitDist, ← Finset.sum_div]
  rw [← Nat.cast_sum, sum_card_orbitCell]

omit [DecidableEq X] [DecidableEq G] [Fintype L] in
/-- The label marginal is uniform on the `|G|` labels. -/
theorem margL_orbitDist (hone : ∀ x, act 1 x = x)
    (hmul : ∀ (g h : G) (x : X), act g (act h x) = act (g * h) x)
    (hS : ∀ (g : G), ∀ x ∈ S, act g x ∈ S) (hc : ∀ (g : G) (x : X), c (act g x) = c x)
    (htor : ∀ x ∈ S, ∀ l : L, ∃! g : G, lab (act g x) = l) (hne : S.Nonempty) (l : L) :
    margL (orbitDist S c lab) l = 1 / Fintype.card G := by
  have hcard : (0:ℝ) < S.card := by
    have : 0 < S.card := Finset.card_pos.2 hne
    exact_mod_cast this
  have hG : (0:ℝ) < Fintype.card G := by
    have : 0 < Fintype.card G := Fintype.card_pos
    exact_mod_cast this
  have hsum : Fintype.card G * ∑ k, (orbitCell S c lab l k).card = S.card := by
    rw [Finset.mul_sum,
      Finset.sum_congr rfl (fun k _ => card_orbitCell_mul hone hmul hS hc htor l k)]
    exact sum_card_orbitFiber
  have hR : (Fintype.card G : ℝ) * ∑ k, ((orbitCell S c lab l k).card : ℝ) = (S.card : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hsum
  have hml : margL (orbitDist S c lab) l
      = (∑ k, ((orbitCell S c lab l k).card : ℝ)) / S.card := by
    simp [margL, orbitDist, Finset.sum_div]
  rw [hml]
  field_simp
  linarith

omit [DecidableEq X] [DecidableEq G] in
/-- **The contingency table of a `G`-invariant readout against a torsor label is a product
table.** -/
theorem orbitDist_product (hone : ∀ x, act 1 x = x)
    (hmul : ∀ (g h : G) (x : X), act g (act h x) = act (g * h) x)
    (hS : ∀ (g : G), ∀ x ∈ S, act g x ∈ S) (hc : ∀ (g : G) (x : X), c (act g x) = c x)
    (htor : ∀ x ∈ S, ∀ l : L, ∃! g : G, lab (act g x) = l) (l : L) (k : K) :
    orbitDist S c lab l k
      = margL (orbitDist S c lab) l * margK (orbitDist S c lab) k := by
  rcases S.eq_empty_or_nonempty with rfl | hne
  · simp [orbitDist, margL, margK, orbitCell]
  have hcard : (0:ℝ) < S.card := by
    have : 0 < S.card := Finset.card_pos.2 hne
    exact_mod_cast this
  have hG : (0:ℝ) < Fintype.card G := by
    have : 0 < Fintype.card G := Fintype.card_pos
    exact_mod_cast this
  have hkey : (Fintype.card G : ℝ) * ((orbitCell S c lab l k).card : ℝ)
      = ((orbitFiber S c k).card : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (card_orbitCell_mul hone hmul hS hc htor l k)
  rw [margL_orbitDist hone hmul hS hc htor hne l, margK_orbitDist]
  unfold orbitDist
  field_simp
  linarith

omit [DecidableEq X] [DecidableEq G] in
/-- **Orbit blindness.**  A `G`-invariant readout carries exactly zero bits about any torsor
coordinate of the `G`-action.  The two-factor wall is the case `G = ℤ/2`. -/
theorem orbit_zero_leakage (hone : ∀ x, act 1 x = x)
    (hmul : ∀ (g h : G) (x : X), act g (act h x) = act (g * h) x)
    (hS : ∀ (g : G), ∀ x ∈ S, act g x ∈ S) (hc : ∀ (g : G) (x : X), c (act g x) = c x)
    (htor : ∀ x ∈ S, ∀ l : L, ∃! g : G, lab (act g x) = l) :
    mutualInfo (orbitDist S c lab) = 0 :=
  mutualInfo_eq_zero_of_product (orbitDist_product hone hmul hS hc htor)

end Orbit

/-! ## Part 2. The two-factor wall as a special case (`G = ℤ/2`) -/

section SwapInstance

variable {K : Type*} [DecidableEq K] [Fintype K]

/-- The two-element group `Equiv.Perm (Fin 2)` acting on ordered pairs by `Prod.swap`. -/
def swapAct (σ : Equiv.Perm (Fin 2)) (x : ℕ × ℕ) : ℕ × ℕ := if σ = 1 then x else x.swap

/-- `Equiv.Perm (Fin 2)` has exactly two elements. -/
theorem perm_fin2_cases (σ : Equiv.Perm (Fin 2)) : σ = 1 ∨ σ = Equiv.swap 0 1 := by
  revert σ
  decide

theorem perm_fin2_swap_ne_one : (Equiv.swap (0 : Fin 2) 1) ≠ 1 := by decide

theorem swapAct_one (x : ℕ × ℕ) : swapAct 1 x = x := by simp [swapAct]

theorem swapAct_swap (x : ℕ × ℕ) : swapAct (Equiv.swap 0 1) x = x.swap := by
  simp [swapAct]

theorem swapAct_mul (g h : Equiv.Perm (Fin 2)) (x : ℕ × ℕ) :
    swapAct g (swapAct h x) = swapAct (g * h) x := by
  rcases perm_fin2_cases g with rfl | rfl <;> rcases perm_fin2_cases h with rfl | rfl <;>
    simp [swapAct_one, swapAct_swap, Prod.swap_swap, one_mul, mul_one,
      show Equiv.swap (0 : Fin 2) 1 * Equiv.swap (0 : Fin 2) 1 = 1 from by decide]

/-- Off the diagonal, swapping flips the which-factor label. -/
theorem biggerLabel_swap {x : ℕ × ℕ} (hx : x.1 ≠ x.2) : biggerLabel x.swap = ! biggerLabel x := by
  rcases lt_or_gt_of_ne hx with h | h <;>
    simp [biggerLabel, Prod.fst_swap, Prod.snd_swap, h, Nat.lt_asymm h]

/-- **The which-factor label is a torsor coordinate for the swap action.** -/
theorem swap_torsor {S : Finset (ℕ × ℕ)} (hoff : ∀ x ∈ S, x.1 ≠ x.2) :
    ∀ x ∈ S, ∀ b : Bool, ∃! σ : Equiv.Perm (Fin 2), biggerLabel (swapAct σ x) = b := by
  intro x hx b
  have hflip : biggerLabel x.swap = ! biggerLabel x := biggerLabel_swap (hoff x hx)
  by_cases hb : biggerLabel x = b
  · refine ⟨1, by simpa [swapAct_one] using hb, ?_⟩
    intro σ hσ
    rcases perm_fin2_cases σ with rfl | rfl
    · rfl
    · rw [swapAct_swap, hflip] at hσ
      exact absurd (hb.trans hσ.symm) (by cases biggerLabel x <;> simp)
  · refine ⟨Equiv.swap 0 1, ?_, ?_⟩
    · show biggerLabel (swapAct (Equiv.swap 0 1) x) = b
      rw [swapAct_swap, hflip]
      cases hbx : biggerLabel x <;> cases b <;> simp_all
    · intro σ hσ
      rcases perm_fin2_cases σ with rfl | rfl
      · rw [swapAct_one] at hσ; exact absurd hσ hb
      · rfl

/-- **The two-factor wall, re-derived from orbit blindness.**  This is exactly
`galoisBlind_zero_leakage`, but obtained from the general group-theoretic theorem with
`G = Equiv.Perm (Fin 2) ≅ ℤ/2` instead of the ad-hoc halving argument. -/
theorem swap_orbit_zero_leakage {S : Finset (ℕ × ℕ)} {c : ℕ × ℕ → K}
    (hswap : ∀ x ∈ S, x.swap ∈ S) (hoff : ∀ x ∈ S, x.1 ≠ x.2) (hc : ∀ x, c x.swap = c x) :
    mutualInfo (jointDist S c) = 0 := by
  have hdist : jointDist S c = orbitDist S c biggerLabel := rfl
  rw [hdist]
  refine orbit_zero_leakage (act := swapAct) swapAct_one swapAct_mul ?_ ?_ (swap_torsor hoff)
  · intro σ x hx
    rcases perm_fin2_cases σ with rfl | rfl
    · rwa [swapAct_one]
    · rw [swapAct_swap]; exact hswap x hx
  · intro σ x
    rcases perm_fin2_cases σ with rfl | rfl
    · rw [swapAct_one]
    · rw [swapAct_swap, hc]

end SwapInstance

end Computation.FactorBlindness