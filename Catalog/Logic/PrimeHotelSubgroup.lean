import Mathlib
import Novelty.PrimeHotelRearrangement

/-!
# Hilbert's Hotel for Primes, deepened: the well-behaved rearrangements form a proper dense subgroup

Building on `Catalog.Novelty.PrimeHotelRearrangement`, where room `n` of the prime hotel holds
the `n`-th prime `p n`, a rearrangement `σ : Equiv.Perm ℕ` is **well behaved** when its
displacement ratio `primeRatio σ n = p (σ n) / p n` tends to `1`.

The earlier file established *density* of the well-behaved rearrangements and the existence of a
*badly behaved* one.  Here we go deeper and settle the algebraic and topological status of the
class `WellBehaved`.

## Main results

* `wellBehaved_comp` — the well-behaved rearrangements are closed under composition.
* `wellBehaved_inv` — they are closed under inversion.
* `wellBehavedSubgroup` — hence they form a **subgroup** of `Sym(ℕ) = Equiv.Perm ℕ`.
* `wellBehavedSubgroup_ne_top` — the subgroup is **proper** (there is a badly behaved
  rearrangement), so it is a *proper dense subgroup*.
* `wellBehavedSubgroup_dense` — restatement of the density theorem inside the subgroup.
* `exists_not_wellBehaved_agree` — **genericity / contrarian result**: the badly behaved
  rearrangements are *also* dense.  For every permutation `σ` and every `N` there is a badly
  behaved permutation agreeing with `σ` on `{0, …, N-1}`.  So membership in the class
  `WellBehaved` is not determined by any finite amount of data: both the class and its complement
  are dense for the topology of pointwise convergence.

The genericity result is powered by a parametrised bad rearrangement `badPermFrom a`, an involution
supported entirely on indices `≥ a` (so it fixes `{0, …, a-1}`) whose displacement ratio is `≥ 2`
infinitely often.
-/

open Filter Topology

namespace PrimeHotel

/-! ### The well-behaved rearrangements are closed under the group operations -/

/-- Any permutation of `ℕ`, being injective, tends to infinity. -/
lemma perm_tendsto_atTop (σ : Equiv.Perm ℕ) : Tendsto (fun n => σ n) atTop atTop :=
  σ.injective.nat_tendsto_atTop

/-- **Closure under composition.** If `σ` and `τ` are well behaved then so is `σ ∘ τ`.
The key identity is `primeRatio (σ*τ) n = primeRatio σ (τ n) * primeRatio τ n`, and
`primeRatio σ (τ n) → 1` because `τ n → ∞`. -/
theorem wellBehaved_comp (σ τ : Equiv.Perm ℕ) (hσ : WellBehaved σ) (hτ : WellBehaved τ) :
    WellBehaved (σ * τ) := by
  have hτtop : Tendsto (fun n => τ n) atTop atTop := perm_tendsto_atTop τ
  have h1 : Tendsto (fun n => primeRatio σ (τ n)) atTop (𝓝 1) := hσ.comp hτtop
  have hmul : Tendsto (fun n => primeRatio σ (τ n) * primeRatio τ n) atTop (𝓝 (1 * 1)) :=
    h1.mul hτ
  rw [one_mul] at hmul
  refine hmul.congr (fun n => ?_)
  simp only [primeRatio, Equiv.Perm.mul_apply]
  have h1 := p_ne_zero_real (τ n)
  have h2 := p_ne_zero_real n
  field_simp

/-- **Closure under inversion.** If `σ` is well behaved then so is `σ⁻¹`.
Here `primeRatio σ⁻¹ n = (primeRatio σ (σ⁻¹ n))⁻¹` and `σ⁻¹ n → ∞`. -/
theorem wellBehaved_inv (σ : Equiv.Perm ℕ) (hσ : WellBehaved σ) : WellBehaved σ⁻¹ := by
  have htop : Tendsto (fun n => σ⁻¹ n) atTop atTop := perm_tendsto_atTop σ⁻¹
  have h1 : Tendsto (fun n => primeRatio σ (σ⁻¹ n)) atTop (𝓝 1) := hσ.comp htop
  have hinv : Tendsto (fun n => (primeRatio σ (σ⁻¹ n))⁻¹) atTop (𝓝 (1 : ℝ)⁻¹) :=
    h1.inv₀ (by norm_num)
  rw [inv_one] at hinv
  refine hinv.congr (fun n => ?_)
  simp only [primeRatio]
  rw [Equiv.Perm.inv_def, Equiv.apply_symm_apply, inv_div]

/-- The well-behaved rearrangements form a **subgroup** of `Sym(ℕ) = Equiv.Perm ℕ`. -/
def wellBehavedSubgroup : Subgroup (Equiv.Perm ℕ) where
  carrier := {σ | WellBehaved σ}
  one_mem' := wellBehaved_one
  mul_mem' := fun {a b} ha hb => wellBehaved_comp a b ha hb
  inv_mem' := fun {a} ha => wellBehaved_inv a ha

@[simp] lemma mem_wellBehavedSubgroup {σ : Equiv.Perm ℕ} :
    σ ∈ wellBehavedSubgroup ↔ WellBehaved σ := Iff.rfl

/-- The well-behaved subgroup is **proper**: some rearrangement is badly behaved. -/
theorem wellBehavedSubgroup_ne_top : wellBehavedSubgroup ≠ ⊤ := by
  obtain ⟨σ, hσ⟩ := exists_not_wellBehaved
  intro h
  exact hσ (mem_wellBehavedSubgroup.1 (h ▸ Subgroup.mem_top σ))

/-- **Density inside the subgroup.** For every permutation `σ` and every `N`, some member of the
well-behaved subgroup agrees with `σ` on `{0, …, N-1}`. -/
theorem wellBehavedSubgroup_dense (σ : Equiv.Perm ℕ) (N : ℕ) :
    ∃ τ ∈ wellBehavedSubgroup, ∀ i < N, τ i = σ i := by
  obtain ⟨τ, hτ, hagree⟩ := wellBehaved_dense σ N
  exact ⟨τ, hτ, hagree⟩

/-! ### A parametrised bad rearrangement supported on `[a, ∞)`

We repeat the long-range-swap construction, but starting the sparse jump sequence at an arbitrary
index `a`, so that every moved point is `≥ a`. -/

/-- A rapidly growing sequence starting at `a`: `jumpSeqFrom a (k+1)` has prime at least twice the
prime of `jumpSeqFrom a k`. -/
noncomputable def jumpSeqFrom (a : ℕ) : ℕ → ℕ
  | 0 => a
  | (k + 1) => (exists_double (jumpSeqFrom a k)).choose

lemma jumpSeqFrom_lt (a k : ℕ) : jumpSeqFrom a k < jumpSeqFrom a (k + 1) :=
  (exists_double (jumpSeqFrom a k)).choose_spec.1

lemma jumpSeqFrom_double (a k : ℕ) : 2 * p (jumpSeqFrom a k) ≤ p (jumpSeqFrom a (k + 1)) :=
  (exists_double (jumpSeqFrom a k)).choose_spec.2

lemma jumpSeqFrom_strictMono (a : ℕ) : StrictMono (jumpSeqFrom a) :=
  strictMono_nat_of_lt_succ (jumpSeqFrom_lt a)

lemma jumpSeqFrom_injective (a : ℕ) : Function.Injective (jumpSeqFrom a) :=
  (jumpSeqFrom_strictMono a).injective

lemma jumpSeqFrom_ge (a k : ℕ) : a ≤ jumpSeqFrom a k := by
  have := (jumpSeqFrom_strictMono a).monotone (Nat.zero_le k)
  simpa [jumpSeqFrom] using this

open Classical in
/-- The underlying involution of the parametrised bad rearrangement: it swaps
`jumpSeqFrom a (2j) ↔ jumpSeqFrom a (2j+1)` for each `j`, and fixes every index not of the form
`jumpSeqFrom a k`. -/
noncomputable def swapFunFrom (a : ℕ) (n : ℕ) : ℕ :=
  if h : ∃ k, jumpSeqFrom a k = n then jumpSeqFrom a (toggle h.choose) else n

lemma swapFunFrom_involutive (a : ℕ) : Function.Involutive (swapFunFrom a) := by
  intro n
  by_cases h : ∃ k, jumpSeqFrom a k = n
  · have e1 : swapFunFrom a n = jumpSeqFrom a (toggle h.choose) := dif_pos h
    have hx : ∃ k, jumpSeqFrom a k = jumpSeqFrom a (toggle h.choose) := ⟨_, rfl⟩
    have e2 : swapFunFrom a (jumpSeqFrom a (toggle h.choose))
        = jumpSeqFrom a (toggle (toggle h.choose)) := by
      rw [swapFunFrom, dif_pos hx]
      congr 2
      exact jumpSeqFrom_injective a hx.choose_spec
    rw [e1, e2, toggle_involutive, h.choose_spec]
  · have hfix : swapFunFrom a n = n := dif_neg h
    rw [hfix, hfix]

/-- The parametrised bad rearrangement as a permutation of `ℕ`. -/
noncomputable def badPermFrom (a : ℕ) : Equiv.Perm ℕ := (swapFunFrom_involutive a).toPerm

lemma badPermFrom_apply (a n : ℕ) : badPermFrom a n = swapFunFrom a n :=
  congrFun (swapFunFrom_involutive a).coe_toPerm n

/-- `badPermFrom a` fixes every index below `a`. -/
theorem badPermFrom_fixes_lt (a : ℕ) : ∀ n, n < a → badPermFrom a n = n := by
  intro n hn
  rw [badPermFrom_apply]
  simp only [swapFunFrom]
  split_ifs with h
  · obtain ⟨k, hk⟩ := h
    have := jumpSeqFrom_ge a k
    omega
  · rfl

lemma swapFunFrom_jumpSeqFrom_even (a j : ℕ) :
    swapFunFrom a (jumpSeqFrom a (2 * j)) = jumpSeqFrom a (2 * j + 1) := by
  rw [swapFunFrom]
  split_ifs with h
  · rw [show h.choose = 2 * j from jumpSeqFrom_injective a h.choose_spec, toggle_even]
  · exact absurd ⟨_, rfl⟩ h

lemma primeRatio_badPermFrom_ge_two (a j : ℕ) :
    2 ≤ primeRatio (badPermFrom a) (jumpSeqFrom a (2 * j)) := by
  rw [primeRatio, badPermFrom_apply, swapFunFrom_jumpSeqFrom_even, le_div_iff₀] <;>
    norm_cast <;>
    linarith [p_pos (jumpSeqFrom a (2 * j)), p_pos (jumpSeqFrom a (2 * j + 1)),
      jumpSeqFrom_double a (2 * j)]

/-- The parametrised bad rearrangement is not well behaved: its displacement ratio is `≥ 2`
infinitely often. -/
theorem not_wellBehaved_badPermFrom (a : ℕ) : ¬ WellBehaved (badPermFrom a) := by
  intro hWB
  have hev := hWB.eventually (gt_mem_nhds (show (1 : ℝ) < 3 / 2 by norm_num))
  rw [Filter.eventually_atTop] at hev
  obtain ⟨M, hM⟩ := hev
  have hbig : M ≤ jumpSeqFrom a (2 * M) :=
    le_trans (by omega) (jumpSeqFrom_strictMono a).le_apply
  have hlt := hM (jumpSeqFrom a (2 * M)) hbig
  have hge := primeRatio_badPermFrom_ge_two a M
  linarith

/-! ### Genericity: the badly behaved rearrangements are dense -/

/-- **Contrarian density.** For every permutation `σ` and every `N` there is a **badly behaved**
rearrangement agreeing with `σ` on `{0, …, N-1}`.  Combined with `wellBehaved_dense`, both the
class of well-behaved rearrangements and its complement are dense: membership in `WellBehaved`
cannot be decided from any finite initial segment. -/
theorem exists_not_wellBehaved_agree (σ : Equiv.Perm ℕ) (N : ℕ) :
    ∃ τ : Equiv.Perm ℕ, ¬ WellBehaved τ ∧ ∀ i < N, τ i = σ i := by
  obtain ⟨f, hfin, hagree⟩ := exists_finiteSupport_perm_agree σ N
  have hf : WellBehaved f := wellBehaved_of_finite_support f hfin
  refine ⟨f * badPermFrom N, ?_, ?_⟩
  · intro hWB
    have hcomp := wellBehaved_comp f⁻¹ (f * badPermFrom N) (wellBehaved_inv f hf) hWB
    rw [inv_mul_cancel_left] at hcomp
    exact not_wellBehaved_badPermFrom N hcomp
  · intro i hi
    rw [Equiv.Perm.mul_apply, badPermFrom_fixes_lt N i hi, hagree i hi]

end PrimeHotel