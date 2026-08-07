import Cryptography.UniversalPosets.ThreePosetBound

/-!
# A superlinear lower bound: `U(n) ≥ n·log₄ n / 6`

`ExactSmall.lean` and `ThreePosetBound.lean` extract lower bounds for
`U(n) = minUniversalSize n` from the *overlap* method: two `n`-element posets
whose largest common induced subposet has `s` points force `2n - s` host points,
and a Bonferroni argument extends this to three posets, giving the linear bound
`3n - ⌈n/2⌉ - 3`.

This file pushes the overlap method to a family of `k` posets and shows that it
is genuinely **superlinear**: it yields

`2·k·4^k ≤ 3·U(4^k)`,  hence  `n · log₄ n ≤ 6 · U(n)`  for all `n`,

so `U(n)/n → ∞`.  This is the lower half of conjecture C2(b) of
`FUTURE_DIRECTIONS.md` (the overlap method reaches order `n log n`).

The family is geometric: for `n = 4^k` and `0 ≤ i < k`, let

`blockChains n (4^i)` = the disjoint union of `4^{k-i}` chains, each of length
`4^i` (blocks of consecutive indices).

Two members of the family are structurally incompatible in a quantitative way:
an induced subposet common to `blockChains n (4^i)` and `blockChains n (4^j)`
with `j < i` has at most `4^{k-i}·4^j` points, because it splits into at most
`4^{k-i}` chains (one per block of the coarse poset) and every chain of it lives
inside a single block of the fine poset, hence has at most `4^j` points.  The
resulting pairwise overlaps sum to at most `k·4^k/3`, so the `k` copies of an
`n`-element poset fill at least `k·4^k − k·4^k/3 = 2k·4^k/3` host points.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Ranked conjectures for this cycle: (1) the overlap
method is not limited to a bounded number of posets, but the gain per extra
poset decays; (2) with a *geometric* family of chain-unions the pairwise
overlaps form a geometric series and hence cost only a constant fraction of the
gain, giving `Ω(n log n)`; (3) with a *linear* family (`d = 1, 2, 3, …`) the
overlaps dominate and nothing is gained; (4) no family can beat `O(n log n)`,
since by Dilworth any two `n`-element posets share a chain or an antichain on
`Ω(log n)` points.

Experiment (Experimenter).  (1) and (2) are formalised below
(`family_lower_bound`, `two_mul_mul_pow_le_three_mul_minUniversalSize`).  For
(3) the same computation with ratio `2` instead of `4` gives
`k·n − k·n = 0`: the geometric series `Σ 2^{i-j}` is exactly `1` per index, so
ratio `2` is the exact threshold of the method — this is why the base `4`
appears.  (4) is left open and restated in `FUTURE_DIRECTIONS.md`.

Analysis (Analyst).  The bound proved here is superlinear but still far below
the counting bound `2^{(n-1)/4} ≤ U(n)` of `LogBounds.lean`; its interest is
methodological: it measures exactly how much *structure* (as opposed to
counting) can force.  The threshold phenomenon at ratio `2` explains why the
three-poset bound of the previous cycle stalled at `5n/2`.

Critique (Critic).  All hypotheses of the Bonferroni step are discharged for the
explicit family; the pairwise bound is proved for arbitrary block sizes (not
just powers of `4`), and the arithmetic is carried out in `ℕ` with the exact
geometric identity `3·Σ_{j<i} 4^j + 1 = 4^i`, so no rounding is hidden.
-/

namespace UniversalPosets

open Function

/-! ## Monotonicity of the overlap bound -/

/-- `CommonInducedBound` is monotone in the bound. -/
theorem CommonInducedBound.mono {n s t : ℕ} {r r' : Fin n → Fin n → Prop}
    (h : CommonInducedBound r r' s) (hst : s ≤ t) : CommonInducedBound r r' t :=
  fun A φ hinj hiso => (h A φ hinj hiso).trans hst

/-! ## Disjoint unions of chains of a fixed block size -/

/--
`blockChains n d` : the disjoint union of chains obtained by cutting
`{0, …, n-1}` into consecutive blocks of length `d`; two points are comparable
exactly when they lie in the same block.
-/
def blockChains (n d : ℕ) : Fin n → Fin n → Prop :=
  fun x y => x ≤ y ∧ (x : ℕ) / d = (y : ℕ) / d

theorem blockChains_isPartialOrder (n d : ℕ) : IsPartialOrder (Fin n) (blockChains n d) :=
  haveI : Std.Refl (blockChains n d) := ⟨fun x => ⟨le_refl x, rfl⟩⟩
  haveI : IsTrans (Fin n) (blockChains n d) :=
    ⟨fun _ _ _ h1 h2 => ⟨le_trans h1.1 h2.1, h1.2.trans h2.2⟩⟩
  haveI : IsPreorder (Fin n) (blockChains n d) := ⟨⟩
  haveI : Std.Antisymm (blockChains n d) := ⟨fun _ _ h1 h2 => le_antisymm h1.1 h2.1⟩
  ⟨⟩

/-- Points in a common block are comparable. -/
theorem blockChains_comparable {n d : ℕ} {x y : Fin n} (h : (x : ℕ) / d = (y : ℕ) / d) :
    blockChains n d x y ∨ blockChains n d y x := by
  rcases le_total x y with hle | hle
  · exact Or.inl ⟨hle, h⟩
  · exact Or.inr ⟨hle, h.symm⟩

/-- `blockChains n 1` is the `n`-element antichain. -/
theorem blockChains_one (n : ℕ) : blockChains n 1 = fun x y => x = y := by
  funext x y
  simp only [blockChains, Nat.div_one]
  exact propext ⟨fun h => Fin.ext h.2, fun h => ⟨le_of_eq h, congrArg Fin.val h⟩⟩

/--
**Pairwise overlap bound for two block-chain posets.**  A common induced
subposet of `blockChains n e` (the coarse one, blocks of size `e`) and
`blockChains n d` (blocks of size `d`) has at most `((n-1)/e + 1)·d` points: it
meets each of the `(n-1)/e + 1` blocks of the coarse poset in a chain, and every
such chain is carried into a single block of the fine poset, hence has at most
`d` points.
-/
theorem commonInducedBound_blockChains (n d e : ℕ) (hd : 0 < d) :
    CommonInducedBound (blockChains n e) (blockChains n d) (((n - 1) / e + 1) * d) := by
  classical
  intro A φ hinj hiso
  set ψ : Fin n → ℕ × ℕ := fun x => ((x : ℕ) / e, ((φ x : ℕ)) % d) with hψ
  have hmaps : Set.MapsTo ψ ↑A ↑((Finset.range ((n - 1) / e + 1)) ×ˢ (Finset.range d)) := by
    intro x _
    have hx : (x : ℕ) ≤ n - 1 := by
      have := x.isLt; omega
    have h1 : (x : ℕ) / e < (n - 1) / e + 1 :=
      Nat.lt_succ_of_le (Nat.div_le_div_right hx)
    have h2 : ((φ x : ℕ)) % d < d := Nat.mod_lt _ hd
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_range, hψ]
    exact ⟨h1, h2⟩
  have hinjψ : Set.InjOn ψ ↑A := by
    intro x hx y hy hxy
    have hblock : (x : ℕ) / e = (y : ℕ) / e := congrArg Prod.fst hxy
    have hmod : ((φ x : ℕ)) % d = ((φ y : ℕ)) % d := congrArg Prod.snd hxy
    -- the images lie in a common block of the fine poset
    have hsame : ((φ x : ℕ)) / d = ((φ y : ℕ)) / d := by
      rcases blockChains_comparable (n := n) (d := e) hblock with h | h
      · exact ((hiso x (Finset.mem_coe.1 hx) y (Finset.mem_coe.1 hy)).1 h).2
      · exact (((hiso y (Finset.mem_coe.1 hy) x (Finset.mem_coe.1 hx)).1 h).2).symm
    have hval : ((φ x : ℕ)) = ((φ y : ℕ)) := by
      have hx' := Nat.div_add_mod ((φ x : ℕ)) d
      have hy' := Nat.div_add_mod ((φ y : ℕ)) d
      rw [hsame, hmod] at hx'
      omega
    exact hinj hx hy (Fin.ext hval)
  have hcard := Finset.card_le_card_of_injOn ψ hmaps hinjψ
  simpa [Finset.card_product] using hcard

/-! ## A Bonferroni bound for a family of sets -/

/--
**Bonferroni lower bound for a union.**  The sizes of finitely many finite sets
sum to at most the size of their union plus the sizes of all pairwise
intersections.
-/
theorem card_sum_le_card_biUnion_add_pairs {α : Type*} [DecidableEq α]
    (k : ℕ) (A : ℕ → Finset α) :
    ∑ i ∈ Finset.range k, (A i).card ≤
      ((Finset.range k).biUnion A).card +
        ∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, (A i ∩ A j).card := by
  induction k with
  | zero => simp
  | succ k ih =>
      have hins : Finset.range (k + 1) = insert k (Finset.range k) := by
        rw [Finset.range_add_one]
      have hnot : k ∉ Finset.range k := by simp
      have hbi : (Finset.range (k + 1)).biUnion A
          = (Finset.range k).biUnion A ∪ A k := by
        rw [hins, Finset.biUnion_insert]
        exact Finset.union_comm _ _
      have hunion := Finset.card_union_add_card_inter
        ((Finset.range k).biUnion A) (A k)
      have hinter : ((Finset.range k).biUnion A ∩ A k).card
          ≤ ∑ j ∈ Finset.range k, (A k ∩ A j).card := by
        have hsub : (Finset.range k).biUnion A ∩ A k
            ⊆ (Finset.range k).biUnion (fun j => A k ∩ A j) := by
          intro a ha
          rw [Finset.mem_inter] at ha
          obtain ⟨j, hj, haj⟩ := Finset.mem_biUnion.1 ha.1
          exact Finset.mem_biUnion.2 ⟨j, hj, Finset.mem_inter.2 ⟨ha.2, haj⟩⟩
        exact (Finset.card_le_card hsub).trans (Finset.card_biUnion_le)
      have hleft : ∑ i ∈ Finset.range (k + 1), (A i).card
          = (∑ i ∈ Finset.range k, (A i).card) + (A k).card := Finset.sum_range_succ _ _
      have hright : ∑ i ∈ Finset.range (k + 1), ∑ j ∈ Finset.range i, (A i ∩ A j).card
          = (∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, (A i ∩ A j).card)
              + ∑ j ∈ Finset.range k, (A k ∩ A j).card := Finset.sum_range_succ _ _
      rw [hleft, hright, hbi]
      omega

/-! ## The family lower bound -/

/--
**Family overlap bound.**  If `r 0, …, r (k-1)` are `n`-element posets whose
pairwise common induced subposets have at most `s i j` points, then any host
containing all of them has at least `k·n − Σ_{j<i} s i j` points.
-/
theorem family_lower_bound {N n k : ℕ} (h : IsUniversalPosetOfSize N n)
    (r : ℕ → Fin n → Fin n → Prop) (hr : ∀ i, IsPartialOrder (Fin n) (r i))
    (s : ℕ → ℕ → ℕ) (hs : ∀ i j, j < i → CommonInducedBound (r i) (r j) (s i j)) :
    k * n ≤ N + ∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, s i j := by
  classical
  obtain ⟨H, hH, hu⟩ := h
  choose f hf using fun i => hu (r i) (hr i)
  set A : ℕ → Finset (Pt N) := fun i => Finset.image (f i) Finset.univ with hA
  have hcard : ∀ i, (A i).card = n := by
    intro i
    have hinj : Injective (f i) := injective_of_host_witness hH (hr i) (hf i)
    simp [hA, Finset.card_image_of_injective _ hinj]
  have hbi : ((Finset.range k).biUnion A).card ≤ N := by
    simpa using Finset.card_le_univ ((Finset.range k).biUnion A)
  have hpairs : ∀ i ∈ Finset.range k, ∀ j ∈ Finset.range i, (A i ∩ A j).card ≤ s i j := by
    intro i _ j hj
    exact card_inter_images_le hH (hr i) (hr j) (hs i j (Finset.mem_range.1 hj)) (hf i) (hf j)
  have hsum : ∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, (A i ∩ A j).card
      ≤ ∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, s i j :=
    Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => hpairs i hi j hj
  have hbon := card_sum_le_card_biUnion_add_pairs k A
  have hleft : ∑ i ∈ Finset.range k, (A i).card = k * n := by
    rw [Finset.sum_congr rfl fun i _ => hcard i]
    simp [mul_comm]
  omega

/-! ## The geometric family -/

/-- The geometric series identity used to sum the overlaps. -/
theorem three_mul_geom_sum (i : ℕ) : 3 * ∑ j ∈ Finset.range i, 4 ^ j + 1 = 4 ^ i := by
  induction i with
  | zero => simp
  | succ i ih =>
      rw [Finset.sum_range_succ, pow_succ]
      omega

/-- The pairwise overlaps of the geometric family sum to at most `k·4^k/3`. -/
theorem geom_overlap_sum_le (k : ℕ) :
    3 * ∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, 4 ^ (k - i) * 4 ^ j ≤ k * 4 ^ k := by
  have hterm : ∀ i ∈ Finset.range k,
      3 * ∑ j ∈ Finset.range i, 4 ^ (k - i) * 4 ^ j ≤ 4 ^ k := by
    intro i hi
    have hik : i ≤ k := le_of_lt (Finset.mem_range.1 hi)
    have hfac : 4 ^ (k - i) * 4 ^ i = 4 ^ k := by
      rw [← pow_add]
      congr 1
      omega
    calc 3 * ∑ j ∈ Finset.range i, 4 ^ (k - i) * 4 ^ j
        = 4 ^ (k - i) * (3 * ∑ j ∈ Finset.range i, 4 ^ j) := by
          rw [← Finset.mul_sum]; ring
      _ ≤ 4 ^ (k - i) * 4 ^ i := by
          have := three_mul_geom_sum i
          exact Nat.mul_le_mul_left _ (by omega)
      _ = 4 ^ k := hfac
  calc 3 * ∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, 4 ^ (k - i) * 4 ^ j
      = ∑ i ∈ Finset.range k, 3 * ∑ j ∈ Finset.range i, 4 ^ (k - i) * 4 ^ j := by
        rw [Finset.mul_sum]
    _ ≤ ∑ _i ∈ Finset.range k, 4 ^ k := Finset.sum_le_sum hterm
    _ = k * 4 ^ k := by simp

/-- The overlap bound for two members of the geometric family, in the form used
by `family_lower_bound`. -/
theorem commonInducedBound_geom {k i j : ℕ} (hik : i < k) :
    CommonInducedBound (blockChains (4 ^ k) (4 ^ i)) (blockChains (4 ^ k) (4 ^ j))
      (4 ^ (k - i) * 4 ^ j) := by
  have hbase := commonInducedBound_blockChains (4 ^ k) (4 ^ j) (4 ^ i)
    (Nat.pow_pos (by norm_num))
  refine hbase.mono ?_
  have hfac : 4 ^ i * 4 ^ (k - i) = 4 ^ k := by
    rw [← pow_add]; congr 1; omega
  have hlt : (4 ^ k - 1) / 4 ^ i < 4 ^ (k - i) := by
    rw [Nat.div_lt_iff_lt_mul (Nat.pow_pos (by norm_num))]
    have hpos : 0 < 4 ^ k := Nat.pow_pos (by norm_num)
    have : 4 ^ (k - i) * 4 ^ i = 4 ^ k := by rw [mul_comm]; exact hfac
    omega
  have : (4 ^ k - 1) / 4 ^ i + 1 ≤ 4 ^ (k - i) := hlt
  exact Nat.mul_le_mul_right _ this

/--
**The superlinear lower bound at powers of four.**  `2·k·4^k ≤ 3·U(4^k)`, i.e.
`U(n) ≥ (2/3)·n·log₄ n` for `n = 4^k`.
-/
theorem two_mul_mul_pow_le_three_mul_minUniversalSize (k : ℕ) :
    2 * (k * 4 ^ k) ≤ 3 * minUniversalSize (4 ^ k) := by
  have hfam := family_lower_bound (N := minUniversalSize (4 ^ k)) (n := 4 ^ k) (k := k)
    (isUniversalPosetOfSize_minUniversalSize (4 ^ k))
    (fun i => blockChains (4 ^ k) (4 ^ i))
    (fun i => blockChains_isPartialOrder (4 ^ k) (4 ^ i))
    (fun i j => 4 ^ (k - i) * 4 ^ j)
    (fun i j _ => by
      by_cases hik : i < k
      · exact commonInducedBound_geom hik
      · -- for `i ≥ k` the coarse poset is a single chain and the bound is trivial
        have hbase := commonInducedBound_blockChains (4 ^ k) (4 ^ j) (4 ^ i)
          (Nat.pow_pos (by norm_num))
        refine hbase.mono ?_
        have hik' : k ≤ i := Nat.not_lt.1 hik
        have h1 : (4 ^ k - 1) / 4 ^ i + 1 ≤ 4 ^ (k - i) := by
          have hmono : (4 : ℕ) ^ k ≤ 4 ^ i := Nat.pow_le_pow_right (by norm_num) hik'
          have hposi : 0 < (4 : ℕ) ^ i := Nat.pow_pos (by norm_num)
          have hle : 4 ^ k - 1 < 4 ^ i := by omega
          have hzero : (4 ^ k - 1) / 4 ^ i = 0 := Nat.div_eq_of_lt hle
          simp [hzero, Nat.sub_eq_zero_of_le hik']
        exact Nat.mul_le_mul_right _ h1)
  have hsum := geom_overlap_sum_le k
  set S := ∑ i ∈ Finset.range k, ∑ j ∈ Finset.range i, 4 ^ (k - i) * 4 ^ j with hS
  set A := k * 4 ^ k with hA
  omega

/-! ## The general form -/

/--
**`U(n) ≥ n·log₄ n / 6` for every `n`.**  Consequently `U(n)/n → ∞`: the
universal-poset size function is superlinear, which no bound of the previous
cycles (all linear) could see.
-/
theorem log_mul_le_six_mul_minUniversalSize (n : ℕ) :
    Nat.log 4 n * n ≤ 6 * minUniversalSize n := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  set k := Nat.log 4 n with hk
  have hle : 4 ^ k ≤ n := Nat.pow_log_le_self 4 (by omega)
  have hlt : n < 4 ^ (k + 1) := Nat.lt_pow_succ_log_self (by norm_num) n
  have hmono : minUniversalSize (4 ^ k) ≤ minUniversalSize n := minUniversalSize_mono hle
  have hbase := two_mul_mul_pow_le_three_mul_minUniversalSize k
  -- `n < 4·4^k`, so `k·n ≤ 4·k·4^k ≤ 6·U(n)`
  have hn4 : n ≤ 4 * 4 ^ k := by
    have : (4 : ℕ) ^ (k + 1) = 4 * 4 ^ k := by ring
    omega
  have hstep : k * n ≤ k * (4 * 4 ^ k) := Nat.mul_le_mul_left _ hn4
  have hstep2 : 2 * (k * 4 ^ k) ≤ 3 * minUniversalSize n := by
    have := Nat.mul_le_mul_left 3 hmono
    omega
  have : k * (4 * 4 ^ k) = 2 * (2 * (k * 4 ^ k)) := by ring
  calc k * n ≤ k * (4 * 4 ^ k) := hstep
    _ = 2 * (2 * (k * 4 ^ k)) := this
    _ ≤ 2 * (3 * minUniversalSize n) := Nat.mul_le_mul_left _ hstep2
    _ = 6 * minUniversalSize n := by ring

/-- **`U` is superlinear**: for every constant `C` there are (arbitrarily large)
`n` with `C·n ≤ U(n)`. -/
theorem minUniversalSize_superlinear (C m : ℕ) :
    ∃ n, m ≤ n ∧ C * n ≤ minUniversalSize n := by
  obtain ⟨k, hk⟩ : ∃ k, 6 * C ≤ Nat.log 4 (4 ^ k) ∧ m ≤ 4 ^ k := by
    refine ⟨max (6 * C) m, ?_, ?_⟩
    · rw [Nat.log_pow (by norm_num)]
      exact le_max_left _ _
    · exact le_trans (Nat.le_of_lt_succ (Nat.lt_succ_of_le (le_max_right (6 * C) m)))
        (Nat.le_of_lt (Nat.lt_pow_self (by norm_num)))
  refine ⟨4 ^ k, hk.2, ?_⟩
  have hmain := log_mul_le_six_mul_minUniversalSize (4 ^ k)
  have hCn : 6 * (C * 4 ^ k) ≤ Nat.log 4 (4 ^ k) * 4 ^ k := by
    have := Nat.mul_le_mul_right (4 ^ k) hk.1
    calc 6 * (C * 4 ^ k) = 6 * C * 4 ^ k := by ring
      _ ≤ Nat.log 4 (4 ^ k) * 4 ^ k := this
  omega

end UniversalPosets