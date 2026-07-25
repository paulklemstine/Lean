import Mathlib

/-!
# Hilbert's Hotel for Primes: rearranging the prime rooms

Hilbert's prime hotel has one room for each natural number, and room `n` holds the `n`-th
prime `p n = Nat.nth Nat.Prime n`.  A *rearrangement* of the guests is a permutation
`σ : Equiv.Perm ℕ`; after the rearrangement room `n` holds the prime `p (σ n)`.  We measure how
much the rooms move by the **displacement ratio**
`primeRatio σ n = p (σ n) / p n`.

A rearrangement is called **well behaved** when the displacement ratio converges to `1`:
asymptotically the guests barely change rooms.

## Main results

* `wellBehaved_of_finite_support` — every finitely supported rearrangement is well behaved;
  in fact its displacement ratio is *eventually equal* to `1`.
* `exists_finiteSupport_perm_agree` — every permutation can be matched, on any finite initial
  segment `{0, …, N-1}`, by a finitely supported permutation.
* `wellBehaved_dense` — **density**: for every permutation `σ` and every `N` there is a
  *well behaved* permutation agreeing with `σ` on `{0, …, N-1}`.  This is exactly the statement
  that the well-behaved rearrangements are dense in the symmetric group `Sym(ℕ)` for the
  topology of pointwise convergence.
* `exists_not_wellBehaved` — **not every rearrangement works**: there is a permutation (an
  involution assembled from a sparse family of long-range swaps) whose displacement ratio is
  `≥ 2` infinitely often, hence does not converge to `1`.

The density statement is elementary yet captures the paper's central claim, and the last result
shows the phenomenon is genuinely not universal.
-/

open Filter Topology

namespace PrimeHotel

/-- Room `n` of the prime hotel holds the `n`-th prime. -/
noncomputable def p (n : ℕ) : ℕ := Nat.nth Nat.Prime n

lemma p_prime (n : ℕ) : Nat.Prime (p n) := Nat.prime_nth_prime n

lemma p_pos (n : ℕ) : 0 < p n := (p_prime n).pos

lemma p_ne_zero_real (n : ℕ) : (p n : ℝ) ≠ 0 := by exact_mod_cast (p_pos n).ne'

lemma p_strictMono : StrictMono p := Nat.nth_strictMono Nat.infinite_setOf_prime

lemma p_injective : Function.Injective p := p_strictMono.injective

lemma p_tendsto_atTop : Tendsto p atTop atTop := p_strictMono.tendsto_atTop

/-- The displacement ratio of room `n` under the rearrangement `σ`. -/
noncomputable def primeRatio (σ : Equiv.Perm ℕ) (n : ℕ) : ℝ := (p (σ n) : ℝ) / (p n : ℝ)

/-- A rearrangement is *well behaved* when its displacement ratios converge to `1`. -/
def WellBehaved (σ : Equiv.Perm ℕ) : Prop := Tendsto (primeRatio σ) atTop (𝓝 1)

/-! ### Finitely supported rearrangements are well behaved -/

/-
A finitely supported permutation is eventually the identity.
-/
lemma eventually_eq_id_of_finite_support (σ : Equiv.Perm ℕ)
    (h : {n | σ n ≠ n}.Finite) : ∃ N, ∀ n ≥ N, σ n = n := by
  exact ⟨ h.bddAbove.some + 1, fun n hn => Classical.not_not.1 fun hnn => not_lt_of_ge ( h.bddAbove.choose_spec hnn ) hn ⟩

/-
If a rearrangement is eventually the identity, then its displacement ratio is eventually
`1`, so it is well behaved.
-/
lemma wellBehaved_of_eventually_id (σ : Equiv.Perm ℕ)
    (h : ∃ N, ∀ n ≥ N, σ n = n) : WellBehaved σ := by
  exact tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ge_atTop h.choose ] with n hn; rw [ primeRatio, h.choose_spec n hn, div_self ( by exact ne_of_gt ( Nat.cast_pos.mpr ( Nat.Prime.pos ( p_prime _ ) ) ) ) ] )

/-- Every finitely supported rearrangement is well behaved. -/
lemma wellBehaved_of_finite_support (σ : Equiv.Perm ℕ)
    (h : {n | σ n ≠ n}.Finite) : WellBehaved σ :=
  wellBehaved_of_eventually_id σ (eventually_eq_id_of_finite_support σ h)

/-- The identity rearrangement (nobody moves) is well behaved. -/
lemma wellBehaved_one : WellBehaved (1 : Equiv.Perm ℕ) :=
  wellBehaved_of_eventually_id 1 ⟨0, by intro n _; rfl⟩

/-! ### Density of the well-behaved rearrangements -/

/-
Any permutation can be matched, on the finite initial segment `{0, …, N-1}`, by a finitely
supported permutation.  Proof is by induction on `N`: to extend agreement from `{0,…,N-1}` to
`{0,…,N}` compose with a single transposition `Equiv.swap (τ N) (σ N)`, which fixes all points
already handled.
-/
lemma exists_finiteSupport_perm_agree (σ : Equiv.Perm ℕ) (N : ℕ) :
    ∃ τ : Equiv.Perm ℕ, {n | τ n ≠ n}.Finite ∧ ∀ i < N, τ i = σ i := by
  induction' N with N ih;
  · exact ⟨ 1, by simp +decide ⟩;
  · obtain ⟨ τ, hτ₁, hτ₂ ⟩ := ih; use Equiv.swap ( τ N ) ( σ N ) * τ; simp_all +decide ;
    refine' ⟨ Set.Finite.subset ( hτ₁.union ( Set.toFinite { τ N, σ N } ) ) _, _ ⟩;
    · grind +qlia;
    · intro i hi; cases lt_or_eq_of_le hi <;> simp_all +decide [ Equiv.swap_apply_def ] ;
      split_ifs <;> simp_all +decide [ ne_of_lt ];
      have := τ.injective ( by aesop : τ i = τ N ) ; aesop;

/-- **Density theorem.** For every permutation `σ` and every `N`, there is a *well behaved*
permutation agreeing with `σ` on `{0, …, N-1}`.  Equivalently, the well-behaved rearrangements
are dense in `Sym(ℕ)` for the topology of pointwise convergence. -/
theorem wellBehaved_dense (σ : Equiv.Perm ℕ) (N : ℕ) :
    ∃ τ : Equiv.Perm ℕ, WellBehaved τ ∧ ∀ i < N, τ i = σ i := by
  obtain ⟨τ, hfin, hagree⟩ := exists_finiteSupport_perm_agree σ N
  exact ⟨τ, wellBehaved_of_finite_support τ hfin, hagree⟩

/-! ### Not every rearrangement is well behaved

We construct an involution `badPerm` that fixes all but a sparse set of indices and, on that
sparse set, performs long-range swaps large enough that the displacement ratio is `≥ 2`
infinitely often. -/

/-
For every `m` there is a strictly larger index whose prime is at least twice `p m`.  This
holds because `p` tends to infinity.
-/
lemma exists_double (m : ℕ) : ∃ b, m < b ∧ 2 * p m ≤ p b := by
  have h_unbounded : ∀ M : ℕ, ∃ b > m, p b > M := by
    intro M
    have := p_tendsto_atTop
    have := this.eventually_gt_atTop M
    have := this.and (Filter.eventually_gt_atTop m)
    obtain ⟨b, hb⟩ := this.exists
    use b
    aesop;
  exact Exists.elim ( h_unbounded ( 2 * p m ) ) fun b hb => ⟨ b, hb.1, hb.2.le ⟩

/-- A rapidly growing sequence of indices: `jumpSeq (k+1)` is chosen so that its prime is at
least twice the prime of `jumpSeq k`. -/
noncomputable def jumpSeq : ℕ → ℕ
  | 0 => 0
  | (k + 1) => (exists_double (jumpSeq k)).choose

lemma jumpSeq_lt (k : ℕ) : jumpSeq k < jumpSeq (k + 1) :=
  (exists_double (jumpSeq k)).choose_spec.1

lemma jumpSeq_double (k : ℕ) : 2 * p (jumpSeq k) ≤ p (jumpSeq (k + 1)) :=
  (exists_double (jumpSeq k)).choose_spec.2

lemma jumpSeq_strictMono : StrictMono jumpSeq := strictMono_nat_of_lt_succ jumpSeq_lt

lemma jumpSeq_injective : Function.Injective jumpSeq := jumpSeq_strictMono.injective

lemma le_jumpSeq (k : ℕ) : k ≤ jumpSeq k := jumpSeq_strictMono.le_apply

/-- Toggle within the consecutive pair `{2j, 2j+1}`: swap `2j ↔ 2j+1`. -/
def toggle (k : ℕ) : ℕ := if k % 2 = 0 then k + 1 else k - 1

lemma toggle_involutive : Function.Involutive toggle := by
  intro k; unfold toggle; split_ifs <;> omega;

lemma toggle_even (j : ℕ) : toggle (2 * j) = 2 * j + 1 := by
  simp [toggle, Nat.mul_mod_right]

open Classical in
/-- The underlying involution of the bad rearrangement: it swaps `jumpSeq (2j) ↔ jumpSeq (2j+1)`
for each `j`, and fixes every index not of the form `jumpSeq k`. -/
noncomputable def swapFun (n : ℕ) : ℕ :=
  if h : ∃ k, jumpSeq k = n then jumpSeq (toggle h.choose) else n

lemma swapFun_involutive : Function.Involutive swapFun := by
  intro n
  by_cases h : ∃ k, jumpSeq k = n;
  · have h_swapFun_n : swapFun n = jumpSeq (toggle h.choose) := by
      exact dif_pos h;
    have h_swapFun_swapFun_n : swapFun (jumpSeq (toggle h.choose)) = jumpSeq (toggle (toggle h.choose)) := by
      convert dif_pos _;
      swap;
      grind;
      exact jumpSeq_injective ( by have := Exists.choose_spec ( show ∃ k', jumpSeq k' = jumpSeq ( toggle h.choose ) from ⟨ _, rfl ⟩ ) ; aesop );
    rw [ h_swapFun_n, h_swapFun_swapFun_n, toggle_involutive, h.choose_spec ];
  · unfold swapFun; aesop;

/-- The bad rearrangement, as a permutation of `ℕ`. -/
noncomputable def badPerm : Equiv.Perm ℕ := swapFun_involutive.toPerm

lemma badPerm_apply (n : ℕ) : badPerm n = swapFun n :=
  congrFun swapFun_involutive.coe_toPerm n

/-
On the even-indexed jump points the involution performs a long-range swap.
-/
lemma swapFun_jumpSeq_even (j : ℕ) : swapFun (jumpSeq (2 * j)) = jumpSeq (2 * j + 1) := by
  unfold swapFun;
  split_ifs with h;
  · rw [ show h.choose = 2 * j from jumpSeq_injective h.choose_spec ] ; unfold toggle; simp +arith +decide;
  · exact False.elim <| h ⟨ _, rfl ⟩

/-
At each even-indexed jump point the displacement ratio of `badPerm` is at least `2`.
-/
lemma primeRatio_badPerm_ge_two (j : ℕ) : 2 ≤ primeRatio badPerm (jumpSeq (2 * j)) := by
  rw [ primeRatio ];
  rw [ badPerm_apply, swapFun_jumpSeq_even, le_div_iff₀ ] <;> norm_cast <;> linarith [ p_pos ( jumpSeq ( 2 * j ) ), p_pos ( jumpSeq ( 2 * j + 1 ) ), jumpSeq_double ( 2 * j ) ]

/-
**Not every rearrangement works.** There is a permutation of `ℕ` whose displacement ratio
does not converge to `1`.
-/
theorem exists_not_wellBehaved : ∃ σ : Equiv.Perm ℕ, ¬ WellBehaved σ := by
  refine ⟨badPerm, fun hWB => ?_⟩
  convert absurd ( hWB.eventually ( gt_mem_nhds <| show ( 1 : ℝ ) < ( 3 / 2 ) by norm_num ) ) _ ; norm_num;
  exact fun n => ⟨ jumpSeq ( 2 * n ), by linarith [ le_jumpSeq ( 2 * n ) ], by linarith [ primeRatio_badPerm_ge_two n ] ⟩

end PrimeHotel