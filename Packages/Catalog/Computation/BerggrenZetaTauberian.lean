import Computation.BerggrenZetaCounting

/-!
# From the counting law to the abscissa: a Tauberian bridge

The two halves of this project — the counting law `N(H) = Θ(H)`
(`BerggrenZeta.N_theta`) and the analytic statement that the abscissa of convergence of the
Berggren tree zeta function is `1` (`BerggrenZeta.zetaAbscissa_eq_one`) — were proved by
completely different means: the first by an elementary coprimality sieve on Euclid seeds, the
second by feeding prime seeds into the tree and invoking the divergence of `Σ 1/p`.

This file ties them together.  We show that the *counting law alone already forces the
divergence of the zeta function at `s = 1`*, i.e. `σ ≥ 1`, by a dyadic (in fact `128`-adic)
block argument: the block of nodes with hypotenuse in `(H, 128H]` contains at least
`128H/50 − 2H = 0.56 H` nodes, each contributing at least `1/(128H)` to the harmonic sum, so
each block contributes a fixed positive amount `≥ 1/300`, and the harmonic sum over the tree is
unbounded.

## Main results

* `hsum_block` : `hsum(128H) ≥ hsum(H) + 1/300` for `H ≥ 512`, purely from `N_theta`.
* `hsum_grow`, `hsum_unbounded` : the harmonic sum `Σ_{c(w) ≤ H} 1/c(w)` diverges, with the
  explicit rate `hsum (512·128^k) ≥ k/300` — i.e. `Σ_{c ≤ H} 1/c ≫ log H`.
* `not_summable_zterm_one_of_counting` : a second, independent proof that `Z(1) = ∞`, this
  time deduced from the counting law rather than from the primes.
* `abscissa_ge_one_of_counting` : consequently `1 ≤ zetaAbscissa`, the counting-theoretic
  half of `zetaAbscissa_eq_one`.
-/

namespace BerggrenZeta

open Finset

noncomputable section

/-- The harmonic sum of the Berggren tree truncated at hypotenuse `H`. -/
noncomputable def hsum (H : ℕ) : ℝ := ∑ p ∈ seedsBelow H, ((hyp p : ℝ))⁻¹

lemma hsum_nonneg (H : ℕ) : 0 ≤ hsum H :=
  Finset.sum_nonneg fun p _ => by positivity

/-- **The block estimate.**  Between `H` and `128H` the tree gains at least `0.56 H` nodes,
each of reciprocal size at least `1/(128H)`; so the truncated harmonic sum increases by a
fixed positive amount.  Only the counting law `N_theta` is used. -/
lemma hsum_block {H : ℕ} (hH : 512 ≤ H) : hsum H + 1 / 300 ≤ hsum (128 * H) := by
  have hHpos : 0 < H := by omega
  have hsub : seedsBelow H ⊆ seedsBelow (128 * H) := seedsBelow_mono (by omega)
  have hsplit :
      (∑ p ∈ seedsBelow (128 * H) \ seedsBelow H, ((hyp p : ℝ))⁻¹) + hsum H = hsum (128 * H) :=
    Finset.sum_sdiff hsub
  -- every node in the block has hypotenuse at most `128 H`
  have hterm : ∀ p ∈ seedsBelow (128 * H) \ seedsBelow H,
      (1 : ℝ) / (128 * (H : ℝ)) ≤ ((hyp p : ℝ))⁻¹ := by
    intro p hp
    have hp' := (Finset.mem_sdiff.1 hp).1
    have hle : hyp p ≤ 128 * H := (mem_seedsBelow.1 hp').2
    have hpos : 0 < hyp p := by
      have h1 := (mem_seedsBelow.1 hp').1
      have := h1.pos
      have := h1.lt
      unfold hyp
      nlinarith
    have hleR : (hyp p : ℝ) ≤ 128 * (H : ℝ) := by exact_mod_cast hle
    have hposR : (0 : ℝ) < (hyp p : ℝ) := by exact_mod_cast hpos
    rw [one_div, inv_le_inv₀ (by positivity) hposR]
    exact hleR
  -- hence the block sum is at least (card of block) / (128 H)
  have hcardsum :
      ((seedsBelow (128 * H) \ seedsBelow H).card : ℝ) * (1 / (128 * (H : ℝ))) ≤
        ∑ p ∈ seedsBelow (128 * H) \ seedsBelow H, ((hyp p : ℝ))⁻¹ := by
    have := Finset.card_nsmul_le_sum (seedsBelow (128 * H) \ seedsBelow H)
      (fun p => ((hyp p : ℝ))⁻¹) (1 / (128 * (H : ℝ))) hterm
    simpa [nsmul_eq_mul] using this
  -- the counting law bounds that cardinality from below
  have hcard : (seedsBelow (128 * H) \ seedsBelow H).card = N (128 * H) - N H :=
    Finset.card_sdiff_of_subset hsub
  have hmono : N H ≤ N (128 * H) := N_mono (by omega)
  have hcardR : ((seedsBelow (128 * H) \ seedsBelow H).card : ℝ)
      = (N (128 * H) : ℝ) - (N H : ℝ) := by
    rw [hcard, Nat.cast_sub hmono]
  have hup : (N H : ℝ) ≤ 2 * (H : ℝ) := by exact_mod_cast N_le H
  have hlow : ((128 * H : ℕ) : ℝ) / 50 ≤ (N (128 * H) : ℝ) := N_ge_of_large (by omega)
  have hcast : ((128 * H : ℕ) : ℝ) = 128 * (H : ℝ) := by push_cast; ring
  rw [hcast] at hlow
  have hHR : (512 : ℝ) ≤ (H : ℝ) := by exact_mod_cast hH
  have hHRpos : (0 : ℝ) < (H : ℝ) := by linarith
  have hblock : (1 : ℝ) / 300 ≤ ∑ p ∈ seedsBelow (128 * H) \ seedsBelow H, ((hyp p : ℝ))⁻¹ := by
    refine le_trans ?_ hcardsum
    rw [hcardR]
    have hkey : (0.56 : ℝ) * (H : ℝ) ≤ (N (128 * H) : ℝ) - (N H : ℝ) := by linarith
    have hstep : (0.56 : ℝ) * (H : ℝ) * (1 / (128 * (H : ℝ)))
        ≤ ((N (128 * H) : ℝ) - (N H : ℝ)) * (1 / (128 * (H : ℝ))) :=
      mul_le_mul_of_nonneg_right hkey (by positivity)
    have hne : (H : ℝ) ≠ 0 := ne_of_gt hHRpos
    have hval : (0.56 : ℝ) * (H : ℝ) * (1 / (128 * (H : ℝ))) = 0.56 / 128 := by
      field_simp
    linarith
  linarith [hsplit]

/-- Iterating the block estimate: the truncated harmonic sum grows at least linearly in the
number of blocks, i.e. logarithmically in `H`. -/
lemma hsum_grow (k : ℕ) : (k : ℝ) / 300 ≤ hsum (512 * 128 ^ k) := by
  induction k with
  | zero =>
      have := hsum_nonneg (512 * 128 ^ (0 : ℕ))
      simpa using this
  | succ k ih =>
      have hk : (512 : ℕ) ≤ 512 * 128 ^ k :=
        Nat.le_mul_of_pos_right 512 (pow_pos (by norm_num) k)
      have hstep := hsum_block hk
      have heq : 128 * (512 * 128 ^ k) = 512 * 128 ^ (k + 1) := by ring
      rw [heq] at hstep
      have : ((k : ℝ) + 1) / 300 = (k : ℝ) / 300 + 1 / 300 := by ring
      push_cast
      linarith

/-- **The harmonic sum over the Berggren tree diverges** — a quantitative consequence of the
counting law `N(H) = Θ(H)`. -/
theorem hsum_unbounded (C : ℝ) : ∃ H : ℕ, C ≤ hsum H := by
  obtain ⟨k, hk⟩ := exists_nat_ge (300 * C)
  refine ⟨512 * 128 ^ k, le_trans ?_ (hsum_grow k)⟩
  rw [le_div_iff₀ (by norm_num : (0:ℝ) < 300)]
  linarith

/-- Any truncation of the harmonic sum is bounded by the value of the zeta function at `1`,
whenever the latter converges. -/
lemma hsum_le_tsum (H : ℕ) (hs : Summable (zterm 1)) : hsum H ≤ ∑' w : List (Fin 3), zterm 1 w := by
  have hseed : Summable (fun q : {p : ℕ × ℕ // IsSeed p} => seedTerm 1 q.1) :=
    (nodeEquiv.summable_iff (f := fun q : {p : ℕ × ℕ // IsSeed p} => seedTerm 1 q.1)).1 hs
  have htsum : ∑' w : List (Fin 3), zterm 1 w
      = ∑' q : {p : ℕ × ℕ // IsSeed p}, seedTerm 1 q.1 :=
    nodeEquiv.tsum_eq (fun q : {p : ℕ × ℕ // IsSeed p} => seedTerm 1 q.1)
  -- transport the truncation into the subtype of seeds
  classical
  set g : {x : ℕ × ℕ // x ∈ seedsBelow H} → {p : ℕ × ℕ // IsSeed p} :=
    fun x => ⟨x.1, (mem_seedsBelow.1 x.2).1⟩ with hg
  have hginj : Function.Injective g := by
    intro x y hxy
    have hxy' : (g x).1 = (g y).1 := congrArg (fun z => z.1) hxy
    exact Subtype.ext hxy'
  have hsumeq : ∑ q ∈ (seedsBelow H).attach.image g, seedTerm 1 q.1 = hsum H := by
    rw [Finset.sum_image (fun x _ y _ h => hginj h)]
    rw [hsum]
    rw [← Finset.sum_attach (seedsBelow H) (fun p => ((hyp p : ℝ))⁻¹)]
    refine Finset.sum_congr rfl ?_
    intro x _
    simp [hg, seedTerm, Real.rpow_neg_one]
  rw [htsum, ← hsumeq]
  exact Summable.sum_le_tsum _ (fun q _ => seedTerm_nonneg 1 q.1) hseed

/-- **Second, independent proof that the Berggren zeta function diverges at `s = 1`.**
Where `not_summable_zterm_one` used the divergence of the sum of prime reciprocals, this proof
uses only the counting law `N(H) = Θ(H)`. -/
theorem not_summable_zterm_one_of_counting : ¬ Summable (zterm 1) := by
  intro hs
  obtain ⟨H, hH⟩ := hsum_unbounded (∑' w : List (Fin 3), zterm 1 w + 1)
  have := hsum_le_tsum H hs
  linarith

/-- The counting-theoretic half of `zetaAbscissa_eq_one`: the abscissa is at least `1`.
The proof below goes through `not_summable_zterm_one_of_counting`, hence relies only on the
counting law and not on the prime-seed argument. -/
theorem abscissa_ge_one_of_counting : 1 ≤ zetaAbscissa := by
  unfold zetaAbscissa
  refine le_csInf ⟨2, summable_zterm (by norm_num)⟩ ?_
  intro s hs
  by_contra hcon
  push_neg at hcon
  exact not_summable_zterm_one_of_counting
    (Summable.of_nonneg_of_le (fun w => Real.rpow_nonneg (by positivity) _)
      (fun w => zterm_mono (le_of_lt hcon) w) hs)

end

end BerggrenZeta