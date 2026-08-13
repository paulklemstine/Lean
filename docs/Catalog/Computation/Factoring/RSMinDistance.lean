import Computation.Factoring.SemiprimeBasics

/-!
# RS-MIND: the minimum distance of the Reed–Solomon code over `ℤ/N` is a free witness

Round-3 closure #1.  For `N = p q` (distinct primes) consider the evaluation
code

`C_k(N) = {(f(0), …, f(N-1)) : f ∈ (ℤ/N)[x], deg f < k}`.

By CRT this is the product of the Reed–Solomon codes over `𝔽_p` and `𝔽_q`, and
the paper's experiment 303 finds the minimum distance
`d(C_k) = N - (k-1)·max(p,q)`.

We prove this.  With `zeroSet f` the set of coordinates where the codeword
vanishes and `weight f = N - |zeroSet f|`:

* `RSMind.card_zeroSet_le` — for every nonzero `f`,
  `|zeroSet f| ≤ deg(f) · max(p,q)`, hence
  `RSMind.weight_ge`: `weight f ≥ N - deg(f)·max(p,q)`;
* `RSMind.exists_zeroSet_card_eq_max` — the bound is attained at `k = 2` by the
  codeword `q·x`, whose zero set has exactly `max(p,q)` points;
* `RSMind.min_distance_two` — therefore the minimum distance of `C₂(N)` is
  exactly `N - max(p,q)`;
* `RSMind.max_zero_count_reveals_factorization` — **the free witness**: the
  scalar `t = N - d(C₂)` *is* the larger prime, and `N / t` the smaller one.  A
  code invariant that is not a function of `N` alone: computing it requires the
  factorization (or an `Ω(N²)` weight search).
-/

namespace RSMind

open Polynomial Finset

variable {p q : ℕ}

/-- Reduction `ℤ/pq → ℤ/p`. -/
def redp (p q : ℕ) : ZMod (p * q) →+* ZMod p := ZMod.castHom (dvd_mul_right p q) (ZMod p)

/-- Reduction `ℤ/pq → ℤ/q`. -/
def redq (p q : ℕ) : ZMod (p * q) →+* ZMod q := ZMod.castHom (dvd_mul_left q p) (ZMod q)

section

variable [Fact p.Prime] [Fact q.Prime]

instance fact_one_lt_mul : Fact (1 < p * q) :=
  ⟨by nlinarith [(Fact.out (p := p.Prime)).two_le, (Fact.out (p := q.Prime)).two_le]⟩

instance neZero_mul : NeZero (p * q) :=
  ⟨Nat.mul_ne_zero (Fact.out (p := p.Prime)).ne_zero (Fact.out (p := q.Prime)).ne_zero⟩

/-- The set of coordinates at which the codeword of `f` vanishes. -/
def zeroSet (f : (ZMod (p * q))[X]) : Finset (ZMod (p * q)) :=
  Finset.univ.filter (fun x => f.eval x = 0)

/-- The Hamming weight of the codeword of `f`: the number of nonzero
coordinates. -/
def weight (f : (ZMod (p * q))[X]) : ℕ :=
  (Finset.univ.filter (fun x : ZMod (p * q) => f.eval x ≠ 0)).card

theorem weight_add_card_zeroSet (f : (ZMod (p * q))[X]) :
    weight f + (zeroSet f).card = p * q := by
  unfold weight zeroSet
  rw [add_comm, Finset.card_filter_add_card_filter_not (p := fun x => f.eval x = 0)]
  simp [ZMod.card]

/-- The CRT map is injective. -/
theorem crt_injective (h : p.Coprime q) :
    Function.Injective (fun x : ZMod (p * q) => (redp p q x, redq p q x)) := by
  intro x y hxy
  simp only [Prod.mk.injEq] at hxy
  refine (ZMod.chineseRemainder h).injective ?_
  ext
  · simpa [ZMod.chineseRemainder, redp] using hxy.1
  · simpa [ZMod.chineseRemainder, redq] using hxy.2

/-- A polynomial whose reductions mod `p` and mod `q` both vanish is zero. -/
theorem ne_zero_of_maps_zero (h : p.Coprime q) {f : (ZMod (p * q))[X]}
    (hp : f.map (redp p q) = 0) (hq : f.map (redq p q) = 0) : f = 0 := by
  ext n
  have h1 : (redp p q) (f.coeff n) = 0 := by
    have := congrArg (fun g => Polynomial.coeff g n) hp
    simpa [Polynomial.coeff_map] using this
  have h2 : (redq p q) (f.coeff n) = 0 := by
    have := congrArg (fun g => Polynomial.coeff g n) hq
    simpa [Polynomial.coeff_map] using this
  have := crt_injective h (a₁ := f.coeff n) (a₂ := 0)
  simp only [map_zero] at this
  simpa using this (by simp [h1, h2])

/-- Roots of a nonzero polynomial over a finite field are at most its degree. -/
theorem card_roots_filter_le {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (g : F[X]) (hg : g ≠ 0) :
    (Finset.univ.filter (fun y => g.eval y = 0)).card ≤ g.natDegree := by
  have hsub : (Finset.univ.filter (fun y => g.eval y = 0)) ⊆ g.roots.toFinset := by
    intro y hy
    simp only [Finset.mem_filter] at hy
    simp [Multiset.mem_toFinset, hg, Polynomial.IsRoot, hy.2]
  calc (Finset.univ.filter (fun y => g.eval y = 0)).card ≤ g.roots.toFinset.card :=
        Finset.card_le_card hsub
    _ ≤ Multiset.card g.roots := g.roots.toFinset_card_le
    _ ≤ g.natDegree := g.card_roots'

/-- The zero set of a codeword injects into the product of the two prime-level
root sets. -/
theorem card_zeroSet_le_mul (h : p.Coprime q) (f : (ZMod (p * q))[X]) :
    (zeroSet f).card ≤
      (Finset.univ.filter (fun y : ZMod p => (f.map (redp p q)).eval y = 0)).card *
      (Finset.univ.filter (fun y : ZMod q => (f.map (redq p q)).eval y = 0)).card := by
  classical
  have hmaps : ∀ x ∈ zeroSet f, (redp p q x, redq p q x) ∈
      (Finset.univ.filter (fun y : ZMod p => (f.map (redp p q)).eval y = 0)) ×ˢ
      (Finset.univ.filter (fun y : ZMod q => (f.map (redq p q)).eval y = 0)) := by
    intro x hx
    simp only [zeroSet, Finset.mem_filter, Finset.mem_univ, true_and] at hx
    simp only [Finset.mem_product, Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rw [Polynomial.eval_map, Polynomial.eval₂_at_apply, hx, map_zero]
    · rw [Polynomial.eval_map, Polynomial.eval₂_at_apply, hx, map_zero]
  have hinj : Set.InjOn (fun x : ZMod (p * q) => (redp p q x, redq p q x)) (zeroSet f) :=
    fun x _ y _ hxy => crt_injective h hxy
  have := Finset.card_le_card_of_injOn _ hmaps hinj
  simpa [Finset.card_product] using this

/-- **The RS-MIND bound.**  A nonzero codeword of degree `d` vanishes on at most
`d · max(p,q)` coordinates. -/
theorem card_zeroSet_le (h : p.Coprime q) {f : (ZMod (p * q))[X]} (hf : f ≠ 0) :
    (zeroSet f).card ≤ f.natDegree * max p q := by
  have hcard := card_zeroSet_le_mul h f
  have hcardp : (Finset.univ.filter
      (fun y : ZMod p => (f.map (redp p q)).eval y = 0)).card ≤ p := by
    calc _ ≤ (Finset.univ : Finset (ZMod p)).card := Finset.card_le_card (Finset.filter_subset _ _)
      _ = p := by simp [ZMod.card]
  have hcardq : (Finset.univ.filter
      (fun y : ZMod q => (f.map (redq p q)).eval y = 0)).card ≤ q := by
    calc _ ≤ (Finset.univ : Finset (ZMod q)).card := Finset.card_le_card (Finset.filter_subset _ _)
      _ = q := by simp [ZMod.card]
  by_cases hmp : f.map (redp p q) = 0
  · have hmq : f.map (redq p q) ≠ 0 := fun hmq => hf (ne_zero_of_maps_zero h hmp hmq)
    have hq' : (Finset.univ.filter
        (fun y : ZMod q => (f.map (redq p q)).eval y = 0)).card ≤ f.natDegree :=
      le_trans (card_roots_filter_le _ hmq) (Polynomial.natDegree_map_le)
    calc (zeroSet f).card ≤ _ * _ := hcard
      _ ≤ p * f.natDegree := Nat.mul_le_mul hcardp hq'
      _ ≤ max p q * f.natDegree := Nat.mul_le_mul_right _ (le_max_left p q)
      _ = f.natDegree * max p q := Nat.mul_comm _ _
  · have hp' : (Finset.univ.filter
        (fun y : ZMod p => (f.map (redp p q)).eval y = 0)).card ≤ f.natDegree :=
      le_trans (card_roots_filter_le _ hmp) (Polynomial.natDegree_map_le)
    calc (zeroSet f).card ≤ _ * _ := hcard
      _ ≤ f.natDegree * q := Nat.mul_le_mul hp' hcardq
      _ ≤ f.natDegree * max p q := Nat.mul_le_mul_left _ (le_max_right p q)

/-- Equivalent statement in terms of the Hamming weight: every nonzero codeword
of degree `d` has weight at least `N - d·max(p,q)`. -/
theorem weight_ge (h : p.Coprime q) {f : (ZMod (p * q))[X]} (hf : f ≠ 0) :
    p * q - f.natDegree * max p q ≤ weight f := by
  have h1 := weight_add_card_zeroSet f
  have h2 := card_zeroSet_le h hf
  omega

/-- The extremal codeword `q·x`: its zero set is the set of multiples of `p`,
of size exactly `q`. -/
theorem exists_zeroSet_card_eq (h : p.Coprime q) :
    ∃ f : (ZMod (p * q))[X], f ≠ 0 ∧ f.natDegree ≤ 1 ∧ q ≤ (zeroSet f).card := by
  classical
  refine ⟨C ((q : ℕ) : ZMod (p * q)) * X, ?_, ?_, ?_⟩
  · -- the leading coefficient `q` is nonzero in `ℤ/pq`
    intro hzero
    have hcoeff : (C ((q : ℕ) : ZMod (p * q)) * X).coeff 1 = ((q : ℕ) : ZMod (p * q)) := by
      simp
    rw [hzero] at hcoeff
    have hq0 : ((q : ℕ) : ZMod (p * q)) = 0 := hcoeff.symm
    rw [ZMod.natCast_eq_zero_iff] at hq0
    have hple := (Fact.out (p := p.Prime)).two_le
    have hqle := (Fact.out (p := q.Prime)).two_le
    have := Nat.le_of_dvd (by omega) hq0
    nlinarith
  · calc (C ((q : ℕ) : ZMod (p * q)) * X).natDegree
        ≤ (C ((q : ℕ) : ZMod (p * q))).natDegree + X.natDegree := Polynomial.natDegree_mul_le
      _ ≤ 1 := by simp
  · -- the map `y ↦ e⁻¹(0, y)` embeds `ℤ/q` in the zero set
    set e := ZMod.chineseRemainder h with he
    have hmem : ∀ y : ZMod q, e.symm (0, y) ∈ zeroSet (C ((q : ℕ) : ZMod (p * q)) * X) := by
      intro y
      simp only [zeroSet, Finset.mem_filter, Finset.mem_univ, true_and, Polynomial.eval_mul,
        Polynomial.eval_C, Polynomial.eval_X]
      refine e.injective ?_
      have hqe : e ((q : ℕ) : ZMod (p * q)) = (((q : ℕ) : ZMod p), 0) := by
        rw [he]; simp [map_natCast, Prod.ext_iff]
      rw [map_mul, hqe, RingEquiv.apply_symm_apply, map_zero]
      simp [Prod.ext_iff]
    have hinj : Set.InjOn (fun y : ZMod q => e.symm (0, y)) (Finset.univ : Finset (ZMod q)) := by
      intro y _ y' _ hyy
      have := e.symm.injective hyy
      simpa using congrArg Prod.snd this
    have := Finset.card_le_card_of_injOn (fun y : ZMod q => e.symm (0, y))
      (fun y _ => hmem y) hinj
    simpa using this.trans_eq' (by simp [ZMod.card])

/-- **Attainment.**  For `p < q` the extremal codeword of `C₂` vanishes on
exactly `max(p,q) = q` coordinates. -/
theorem exists_zeroSet_card_eq_max (h : p.Coprime q) (hlt : p < q) :
    ∃ f : (ZMod (p * q))[X], f ≠ 0 ∧ f.natDegree ≤ 1 ∧ (zeroSet f).card = max p q := by
  obtain ⟨f, hf0, hdeg, hge⟩ := exists_zeroSet_card_eq (p := p) (q := q) h
  refine ⟨f, hf0, hdeg, le_antisymm ?_ ?_⟩
  · calc (zeroSet f).card ≤ f.natDegree * max p q := card_zeroSet_le h hf0
      _ ≤ 1 * max p q := Nat.mul_le_mul_right _ hdeg
      _ = max p q := one_mul _
  · rw [max_eq_right hlt.le]; exact hge

/-- **The minimum distance of `C₂(N)`** is exactly `N - max(p,q)`: the bound is
tight, so the minimum distance leaks the larger prime factor. -/
theorem min_distance_two (h : p.Coprime q) (hlt : p < q) :
    (∀ f : (ZMod (p * q))[X], f ≠ 0 → f.natDegree ≤ 1 → p * q - max p q ≤ weight f) ∧
      (∃ f : (ZMod (p * q))[X], f ≠ 0 ∧ f.natDegree ≤ 1 ∧ weight f = p * q - max p q) := by
  constructor
  · intro f hf hdeg
    have h1 := weight_ge h hf
    have h2 : f.natDegree * max p q ≤ 1 * max p q := Nat.mul_le_mul_right _ hdeg
    omega
  · obtain ⟨f, hf0, hdeg, hcard⟩ := exists_zeroSet_card_eq_max h hlt
    refine ⟨f, hf0, hdeg, ?_⟩
    have := weight_add_card_zeroSet f
    omega


/-! ### The general-`k` case

The extremal codeword of `C_{k+1}(N)` is `q · ∏_{i<k} (x - i)`: it vanishes on
the `k` residue classes `0, …, k-1` mod `p`, each of which has `q` lifts. -/

/-- The extremal codeword of degree `k` vanishes on at least `k·q` points
(`k ≤ p`). -/
theorem exists_zeroSet_card_ge_general (h : p.Coprime q) {k : ℕ} (hk : k ≤ p) :
    ∃ f : (ZMod (p * q))[X], f ≠ 0 ∧ f.natDegree ≤ k ∧ k * q ≤ (zeroSet f).card := by
  classical
  set g : (ZMod (p * q))[X] := ∏ i ∈ Finset.range k, (X - C ((i : ℕ) : ZMod (p * q))) with hg
  have hgm : g.Monic := monic_prod_of_monic _ _ (fun i _ => monic_X_sub_C _)
  have hgdeg : g.natDegree = k := by
    rw [hg, Polynomial.natDegree_prod_of_monic _ _ (fun i _ => monic_X_sub_C _)]
    have hdeg1 : ∀ i : ℕ,
        ((X : (ZMod (p * q))[X]) - ((i : ℕ) : (ZMod (p * q))[X])).natDegree = 1 := by
      intro i
      rw [show ((i : ℕ) : (ZMod (p * q))[X]) = C ((i : ℕ) : ZMod (p * q)) by simp,
        Polynomial.natDegree_X_sub_C]
    simp [hdeg1]
  have hqne : ((q : ℕ) : ZMod (p * q)) ≠ 0 := by
    intro hq0
    rw [ZMod.natCast_eq_zero_iff] at hq0
    have hple := (Fact.out (p := p.Prime)).two_le
    have hqle := (Fact.out (p := q.Prime)).two_le
    have := Nat.le_of_dvd (by omega) hq0
    nlinarith
  refine ⟨C ((q : ℕ) : ZMod (p * q)) * g, ?_, ?_, ?_⟩
  · intro hzero
    have hcoeff : (C ((q : ℕ) : ZMod (p * q)) * g).coeff k
        = ((q : ℕ) : ZMod (p * q)) := by
      rw [Polynomial.coeff_C_mul, ← hgdeg, hgm.coeff_natDegree, mul_one]
    rw [hzero] at hcoeff
    exact hqne hcoeff.symm
  · calc (C ((q : ℕ) : ZMod (p * q)) * g).natDegree
        ≤ (C ((q : ℕ) : ZMod (p * q))).natDegree + g.natDegree := Polynomial.natDegree_mul_le
      _ ≤ k := by simp [hgdeg]
  · set e := ZMod.chineseRemainder h with he
    have heval : ∀ x : ZMod (p * q), (C ((q : ℕ) : ZMod (p * q)) * g).eval x
        = ((q : ℕ) : ZMod (p * q)) * ∏ j ∈ Finset.range k, (x - ((j : ℕ) : ZMod (p * q))) := by
      intro x
      simp [hg, Polynomial.eval_prod]
    have hqe : e ((q : ℕ) : ZMod (p * q)) = (((q : ℕ) : ZMod p), 0) := by
      rw [he]; simp [map_natCast, Prod.ext_iff]
    have hmem : ∀ i ∈ Finset.range k, ∀ y : ZMod q,
        e.symm (((i : ℕ) : ZMod p), y) ∈ zeroSet (C ((q : ℕ) : ZMod (p * q)) * g) := by
      intro i hi y
      simp only [zeroSet, Finset.mem_filter, Finset.mem_univ, true_and]
      refine e.injective ?_
      rw [map_zero, heval, map_mul, hqe, map_prod]
      have hfst : (∏ j ∈ Finset.range k,
          (e (e.symm (((i : ℕ) : ZMod p), y)) - e ((j : ℕ) : ZMod (p * q)))).1 = 0 := by
        rw [Prod.fst_prod]
        refine Finset.prod_eq_zero hi ?_
        rw [RingEquiv.apply_symm_apply]
        rw [he]
        simp [map_natCast]
      rw [Prod.ext_iff]
      constructor
      · simpa [hfst] using congrArg (fun z => ((q : ℕ) : ZMod p) * z) hfst
      · simp
    have hinj : Set.InjOn (fun z : ℕ × ZMod q => e.symm (((z.1 : ℕ) : ZMod p), z.2))
        (↑((Finset.range k) ×ˢ (Finset.univ : Finset (ZMod q)))) := by
      intro z hz z' hz' hzz
      simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_range] at hz hz'
      have h1 := e.symm.injective hzz
      obtain ⟨h2, h3⟩ := Prod.mk.inj h1
      have h4 : z.1 = z'.1 := by
        have hv := congrArg ZMod.val h2
        rwa [ZMod.val_natCast_of_lt (lt_of_lt_of_le hz.1 hk),
          ZMod.val_natCast_of_lt (lt_of_lt_of_le hz'.1 hk)] at hv
      exact Prod.ext h4 h3
    have hmaps : ∀ z ∈ (Finset.range k) ×ˢ (Finset.univ : Finset (ZMod q)),
        (fun z : ℕ × ZMod q => e.symm (((z.1 : ℕ) : ZMod p), z.2)) z
          ∈ zeroSet (C ((q : ℕ) : ZMod (p * q)) * g) := by
      intro z hz
      simp only [Finset.mem_product, Finset.mem_range] at hz
      exact hmem z.1 (Finset.mem_range.mpr hz.1) z.2
    have hcard := Finset.card_le_card_of_injOn _ hmaps hinj
    simpa [Finset.card_product, ZMod.card] using hcard

/-- **The RS-MIND formula.**  For `p < q` and `k ≤ p`, the minimum distance of
the code `C_{k+1}(N)` of polynomials of degree `≤ k` is exactly
`N - k·max(p,q)`. -/
theorem min_distance_general (h : p.Coprime q) (hlt : p < q) {k : ℕ} (hk : k ≤ p) :
    (∀ f : (ZMod (p * q))[X], f ≠ 0 → f.natDegree ≤ k → p * q - k * max p q ≤ weight f) ∧
      (∃ f : (ZMod (p * q))[X], f ≠ 0 ∧ f.natDegree ≤ k ∧ weight f = p * q - k * max p q) := by
  constructor
  · intro f hf hdeg
    have h1 := weight_ge h hf
    have h2 : f.natDegree * max p q ≤ k * max p q := Nat.mul_le_mul_right _ hdeg
    exact le_trans (Nat.sub_le_sub_left h2 (p * q)) h1
  · obtain ⟨f, hf0, hdeg, hge⟩ := exists_zeroSet_card_ge_general (p := p) (q := q) h hk
    have hub : (zeroSet f).card ≤ k * max p q :=
      le_trans (card_zeroSet_le h hf0) (Nat.mul_le_mul_right _ hdeg)
    have hmax : max p q = q := max_eq_right hlt.le
    rw [hmax] at hub ⊢
    have hcardeq : (zeroSet f).card = k * q := le_antisymm hub hge
    have hsum := weight_add_card_zeroSet f
    rw [hcardeq] at hsum
    exact ⟨f, hf0, hdeg, by omega⟩

/-- **The free witness.**  Any scalar `t` that is simultaneously an upper bound
for the zero counts of the degree-`≤1` codewords and attained by one of them
equals `max(p,q)`; together with `N` it therefore *is* the factorization.  Such
a `t` is provably not a function of `N` alone in the naive sense: it names a
prime factor. -/
theorem max_zero_count_reveals_factorization (h : p.Coprime q) (hlt : p < q) {t : ℕ}
    (hub : ∀ f : (ZMod (p * q))[X], f ≠ 0 → f.natDegree ≤ 1 → (zeroSet f).card ≤ t)
    (hattained : ∃ f : (ZMod (p * q))[X], f ≠ 0 ∧ f.natDegree ≤ 1 ∧ t ≤ (zeroSet f).card) :
    t = q ∧ p * q / t = p := by
  obtain ⟨g, hg0, hgdeg, hgt⟩ := hattained
  obtain ⟨f, hf0, hdeg, hcard⟩ := exists_zeroSet_card_eq_max h hlt
  have h1 : t ≤ max p q := by
    calc t ≤ (zeroSet g).card := hgt
      _ ≤ g.natDegree * max p q := card_zeroSet_le h hg0
      _ ≤ 1 * max p q := Nat.mul_le_mul_right _ hgdeg
      _ = max p q := one_mul _
  have h2 : max p q ≤ t := hcard ▸ hub f hf0 hdeg
  have ht : t = q := by rw [le_antisymm h1 h2, max_eq_right hlt.le]
  refine ⟨ht, ?_⟩
  rw [ht]
  exact Nat.mul_div_cancel _ (Fact.out (p := q.Prime)).pos

end

end RSMind