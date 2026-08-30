import Cryptography.BerggrenModular.TrialDivisionEquivalence

/-!
# Why `ρ` dominates: an unconditional quadratic separation from the gcd dive

Experiment 555 reports that the modular Berggren dive is trial-division-class
(`α = 1.007 ± 0.088`) and that "ρ dominates by orders of magnitude".  The first
half is proved in `Cryptography.BerggrenModular.TrialDivisionEquivalence`
(`Dive.trial_division_scaling`: a value-testing dive needs `Ω(p_min)` nodes).
This file proves the second half in the same finite model, so that the two
statements are directly comparable.

The `ρ` paradigm does not test values, it tests *pairs*: a stream `f` splits `N`
as soon as two of its values are distinct but congruent modulo an unknown prime
factor `p`, because then `gcd(f j − f i, N) = p` exactly
(`collision_gives_factor`).  Counting the streams *without* such a pair through
an injection into `(Fin t ↪ Fin p) × (Fin t → Fin q)` and a two-term binomial
bound gives the birthday threshold: `t = 2⌈√p⌉` nodes already succeed on at least
`30%` of streams.

Together:

* value dive at `t` nodes: success `< 1/2` whenever `4t < p`   (`Dive.trial_division_scaling`);
* pair test at `t = 2m` nodes: success `≥ 3/10` whenever `p ≤ m²` (`rho_birthday_success`).

so at the *same* node budget `t ≍ √p` the pair test already wins outright — an
unconditional, fully formal statement of the `ρ`-dominates finding.

## Main results

* `collision_gives_factor` — a distinct congruent pair yields the factor `p` exactly.
* `card_injMod_le` — collision-free streams inject into embeddings × fibres.
* `birthday_desc` — `2·p^{\underline{2m}} ≤ p^{2m}` once `p ≤ m²`.
* `card_noRho_le` — the complement bound.
* `rho_birthday_success` — **`3·N^t ≤ 10·#successes` at `t = 2m`, `p ≤ m²`.**
* `rho_dominates_dive` — both statements at once, same budget.
* `rho_dominates_dive_concrete` — an explicit modulus `N = 101·487`, `t = 22`.
-/

namespace Cryptography
namespace BerggrenModular
namespace Dive

/-! ## A collision modulo `p` splits `N` -/

/-- **A distinct congruent pair reveals the factor.**  If `x < y < N = p·q` and
`x ≡ y (mod p)` then `gcd (y − x) N` is exactly `p`.  This is what makes the
pair test a factoring algorithm. -/
theorem collision_gives_factor {p q x y : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hy : y < p * q) (hxy : x < y) (hmod : x % p = y % p) :
    Nat.gcd (y - x) (p * q) = p := by
  have hp0 : 0 < p := hp.pos
  have hd : p ∣ y - x := (Nat.modEq_iff_dvd' hxy.le).1 hmod
  have hdpos : 0 < y - x := by omega
  have hdlt : y - x < p * q := by omega
  obtain ⟨k, hk⟩ : p ∣ Nat.gcd (y - x) (p * q) := Nat.dvd_gcd hd (dvd_mul_right p q)
  have hgd : Nat.gcd (y - x) (p * q) ∣ p * q := Nat.gcd_dvd_right _ _
  have hkq : k ∣ q := by
    rw [hk] at hgd
    exact (mul_dvd_mul_iff_left (by omega : p ≠ 0)).1 hgd
  rcases Nat.Prime.eq_one_or_self_of_dvd hq k hkq with h1 | h1
  · rw [hk, h1, mul_one]
  · exfalso
    have hdvd : Nat.gcd (y - x) (p * q) ∣ y - x := Nat.gcd_dvd_left _ _
    rw [hk, h1] at hdvd
    have := Nat.le_of_dvd hdpos hdvd
    omega

/-- The `ρ`-style success event: the stream contains two distinct values that are
congruent modulo `p`. -/
def RhoHit (p : ℕ) {t : ℕ} (f : Fin t → ℕ) : Prop :=
  ∃ i j : Fin t, f i ≠ f j ∧ f i % p = f j % p

instance (p t : ℕ) : DecidablePred (fun f : Fin t → ℕ => RhoHit p f) :=
  fun f => inferInstanceAs (Decidable (∃ i j : Fin t, f i ≠ f j ∧ f i % p = f j % p))

/-- The streams on which the pair test succeeds. -/
def rhoHitSet (p q t : ℕ) : Finset (Fin t → ℕ) :=
  (samples (p * q) t).filter (fun f => RhoHit p f)

/-- Success of the pair test really is a factorisation: on a hit one can exhibit
two indices whose value difference has `gcd` exactly `p` with `N`. -/
theorem rhoHit_yields_factor {p q t : ℕ} (hp : p.Prime) (hq : q.Prime)
    {f : Fin t → ℕ} (hf : f ∈ rhoHitSet p q t) :
    ∃ i j : Fin t, f i < f j ∧ Nat.gcd (f j - f i) (p * q) = p := by
  rw [rhoHitSet, Finset.mem_filter] at hf
  obtain ⟨hmem, i, j, hne, hmod⟩ := hf
  simp only [samples, Fintype.mem_piFinset, Finset.mem_range] at hmem
  rcases Nat.lt_or_ge (f i) (f j) with h | h
  · exact ⟨i, j, h, collision_gives_factor hp hq (hmem j) h hmod⟩
  · have hlt : f j < f i := by omega
    exact ⟨j, i, hlt, collision_gives_factor hp hq (hmem i) hlt hmod.symm⟩

/-! ## Counting the collision-free streams -/

/-- Streams whose values are pairwise distinct modulo `p` inject into
`(Fin t ↪ Fin p) × (Fin t → Fin q)` by `f ↦ (f mod p, f div p)`. -/
theorem card_injMod_le (p q t : ℕ) (hp : 0 < p) (hq : 0 < q) :
    ((samples (p * q) t).filter (fun f => Function.Injective (fun i => f i % p))).card
      ≤ p.descFactorial t * q ^ t := by
  classical
  have hcard : ((Finset.univ.filter (fun g : Fin t → Fin p => Function.Injective g)) ×ˢ
      (Finset.univ : Finset (Fin t → Fin q))).card = p.descFactorial t * q ^ t := by
    rw [Finset.card_product]
    congr 1
    · rw [← Fintype.card_subtype,
        Fintype.card_congr (Equiv.subtypeInjectiveEquivEmbedding (Fin t) (Fin p))]
      simp [Fintype.card_embedding_eq]
    · simp [Finset.card_univ]
  rw [← hcard]
  refine Finset.card_le_card_of_injOn
    (fun f => (fun i => (⟨f i % p, Nat.mod_lt _ hp⟩ : Fin p),
               fun i => (⟨(f i / p) % q, Nat.mod_lt _ hq⟩ : Fin q))) ?_ ?_
  · intro f hf
    rw [Finset.mem_coe, Finset.mem_filter] at hf
    refine Finset.mem_coe.2 (Finset.mem_product.2
      ⟨Finset.mem_filter.2 ⟨Finset.mem_univ _, ?_⟩, Finset.mem_univ _⟩)
    intro i j hij
    exact hf.2 (congrArg Fin.val hij)
  · intro f hf g hg hfg
    simp only [Finset.coe_filter, Set.mem_setOf_eq, samples, Fintype.mem_piFinset,
      Finset.mem_range] at hf hg
    funext i
    have h1 : f i % p = g i % p := congrArg Fin.val (congrFun (congrArg Prod.fst hfg) i)
    have h2 : (f i / p) % q = (g i / p) % q :=
      congrArg Fin.val (congrFun (congrArg Prod.snd hfg) i)
    have hf1 : f i / p < q := Nat.div_lt_of_lt_mul (hf.1 i)
    have hg1 : g i / p < q := Nat.div_lt_of_lt_mul (hg.1 i)
    rw [Nat.mod_eq_of_lt hf1, Nat.mod_eq_of_lt hg1] at h2
    have e1 := Nat.div_add_mod (f i) p
    have e2 := Nat.div_add_mod (g i) p
    rw [h1, h2] at e1
    omega

/-- Streams that repeat a value at a fixed pair of indices: at most `N^{t−1}`. -/
theorem card_pair_le (N t : ℕ) {i j : Fin t} (hij : i ≠ j) :
    ((samples N t).filter (fun f => f i = f j)).card ≤ N ^ (t - 1) := by
  classical
  have ht2 : 2 ≤ t := by
    have hi := i.isLt
    by_contra h
    interval_cases t
    · exact absurd hi (by omega)
    · exact hij (Subsingleton.elim i j)
  have hsub : (samples N t).filter (fun f => f i = f j) ⊆
      (Finset.range N).biUnion (fun v =>
        Fintype.piFinset (fun k => if k ∈ ({i, j} : Finset (Fin t)) then ({v} : Finset ℕ)
          else Finset.range N)) := by
    intro f hf
    rw [Finset.mem_filter] at hf
    obtain ⟨hmem, heq⟩ := hf
    simp only [samples, Fintype.mem_piFinset, Finset.mem_range] at hmem
    refine Finset.mem_biUnion.2 ⟨f i, Finset.mem_range.2 (hmem i), ?_⟩
    rw [Fintype.mem_piFinset]
    intro k
    by_cases hk : k ∈ ({i, j} : Finset (Fin t))
    · simp only [hk, if_pos, Finset.mem_singleton]
      simp only [Finset.mem_insert, Finset.mem_singleton] at hk
      rcases hk with rfl | rfl
      · rfl
      · exact heq.symm
    · simpa [hk] using Finset.mem_range.2 (hmem k)
  calc ((samples N t).filter (fun f => f i = f j)).card
      ≤ _ := Finset.card_le_card hsub
    _ ≤ ∑ v ∈ Finset.range N, (Fintype.piFinset (fun k =>
          if k ∈ ({i, j} : Finset (Fin t)) then ({v} : Finset ℕ) else Finset.range N)).card :=
        Finset.card_biUnion_le
    _ = N * N ^ (t - 2) := by
        simp only [card_piFinset_ite, Finset.card_singleton, Finset.card_range, one_pow, one_mul]
        rw [Finset.sum_const, Finset.card_range, smul_eq_mul]
        congr 2
        rw [Finset.card_insert_of_notMem (by simpa using hij), Finset.card_singleton]
    _ = N ^ (t - 1) := by
        rw [← pow_succ']
        congr 1
        omega

/-- Streams that repeat some value: at most `t(t−1)·N^{t−1}`. -/
theorem card_nonInj_le (N t : ℕ) :
    ((samples N t).filter (fun f => ¬ Function.Injective f)).card
      ≤ (t * t - t) * N ^ (t - 1) := by
  classical
  have hsub : (samples N t).filter (fun f => ¬ Function.Injective f) ⊆
      (Finset.univ : Finset (Fin t)).offDiag.biUnion
        (fun ij => (samples N t).filter (fun f => f ij.1 = f ij.2)) := by
    intro f hf
    rw [Finset.mem_filter] at hf
    obtain ⟨a, b, hab, hne⟩ := Function.not_injective_iff.1 hf.2
    exact Finset.mem_biUnion.2 ⟨(a, b), Finset.mem_offDiag.2 ⟨Finset.mem_univ _,
      Finset.mem_univ _, hne⟩, Finset.mem_filter.2 ⟨hf.1, hab⟩⟩
  calc ((samples N t).filter (fun f => ¬ Function.Injective f)).card
      ≤ _ := Finset.card_le_card hsub
    _ ≤ ∑ _ij ∈ (Finset.univ : Finset (Fin t)).offDiag, N ^ (t - 1) := by
        refine le_trans Finset.card_biUnion_le (Finset.sum_le_sum ?_)
        intro ij hij
        exact card_pair_le N t (Finset.mem_offDiag.1 hij).2.2
    _ = (t * t - t) * N ^ (t - 1) := by
        rw [Finset.sum_const, smul_eq_mul, Finset.offDiag_card]
        simp

/-- **The complement bound.**  A stream without an exploitable collision either has
pairwise distinct residues mod `p`, or repeats a value outright. -/
theorem card_noRho_le (p q t : ℕ) (hp : 0 < p) (hq : 0 < q) :
    ((samples (p * q) t).filter (fun f => ¬ RhoHit p f)).card
      ≤ p.descFactorial t * q ^ t + (t * t - t) * (p * q) ^ (t - 1) := by
  classical
  have hsub : (samples (p * q) t).filter (fun f => ¬ RhoHit p f) ⊆
      ((samples (p * q) t).filter (fun f => Function.Injective (fun i => f i % p)))
        ∪ ((samples (p * q) t).filter (fun f => ¬ Function.Injective f)) := by
    intro f hf
    rw [Finset.mem_filter] at hf
    by_cases hinj : Function.Injective f
    · refine Finset.mem_union_left _ (Finset.mem_filter.2 ⟨hf.1, ?_⟩)
      intro i j hij
      by_cases hval : f i = f j
      · exact hinj hval
      · exact absurd ⟨i, j, hval, hij⟩ hf.2
    · exact Finset.mem_union_right _ (Finset.mem_filter.2 ⟨hf.1, hinj⟩)
  calc ((samples (p * q) t).filter (fun f => ¬ RhoHit p f)).card
      ≤ _ := Finset.card_le_card hsub
    _ ≤ ((samples (p * q) t).filter (fun f => Function.Injective (fun i => f i % p))).card
          + ((samples (p * q) t).filter (fun f => ¬ Function.Injective f)).card :=
        Finset.card_union_le _ _
    _ ≤ p.descFactorial t * q ^ t + (t * t - t) * (p * q) ^ (t - 1) :=
        Nat.add_le_add (card_injMod_le p q t hp hq) (card_nonInj_le _ _)

/-! ## The birthday inequality -/

/-- The falling factorial after `a` steps is bounded by `p^a · (p−a)^b`. -/
theorem descFactorial_le (p a b : ℕ) : p.descFactorial (a + b) ≤ p ^ a * (p - a) ^ b := by
  induction b with
  | zero => simpa using Nat.descFactorial_le_pow p a
  | succ n ih =>
      rw [show a + (n + 1) = (a + n) + 1 by ring, Nat.descFactorial_succ]
      calc (p - (a + n)) * p.descFactorial (a + n)
          ≤ (p - a) * (p ^ a * (p - a) ^ n) :=
            Nat.mul_le_mul (Nat.sub_le_sub_left (Nat.le_add_right a n) p) ih
        _ = p ^ a * (p - a) ^ (n + 1) := by ring

/-- The two-term binomial bound `p^{k+1} + (k+1)·d·p^k ≤ (p+d)^{k+1}`. -/
theorem two_term_binomial (p d k : ℕ) :
    p ^ (k + 1) + (k + 1) * d * p ^ k ≤ (p + d) ^ (k + 1) := by
  induction k with
  | zero => simp
  | succ n ih =>
      calc p ^ (n + 2) + (n + 2) * d * p ^ (n + 1)
          ≤ p ^ (n+2) + d * p ^ (n+1) + (n+1) * d * p ^ (n+1) + (n+1) * d * d * p ^ n := by
            ring_nf; omega
        _ = (p + d) * (p ^ (n + 1) + (n + 1) * d * p ^ n) := by ring
        _ ≤ (p + d) * (p + d) ^ (n + 1) := Nat.mul_le_mul_left _ ih
        _ = (p + d) ^ (n + 2) := by ring

/-- **The birthday inequality.**  Once `p ≤ m²`, fewer than half of all `2m`-tuples
of residues mod `p` are pairwise distinct. -/
theorem birthday_desc {p m : ℕ} (hp : 1 ≤ p) (hmp : p ≤ m * m) :
    2 * p.descFactorial (2 * m) ≤ p ^ (2 * m) := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp at hmp; omega
  obtain ⟨k, hk⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
  have h1 : p.descFactorial (2 * m) ≤ p ^ m * (p - m) ^ m := by
    have h := descFactorial_le p m m
    rwa [show m + m = 2 * m by ring] at h
  have hmul : (p - m) * (p + m) ≤ p * p := by
    rcases Nat.lt_or_ge p m with h | h
    · have hz : p - m = 0 := by omega
      simp [hz]
    · have h1' : p - m + m = p := by omega
      nlinarith [Nat.sub_le p m]
  have h2 : (p - m) ^ m * (p + m) ^ m ≤ p ^ (2 * m) := by
    calc (p - m) ^ m * (p + m) ^ m = ((p - m) * (p + m)) ^ m := by rw [mul_pow]
      _ ≤ (p * p) ^ m := Nat.pow_le_pow_left hmul m
      _ = p ^ (2 * m) := by rw [show p * p = p ^ 2 by ring, ← pow_mul]
  have h3 : 2 * p ^ m ≤ (p + m) ^ m := by
    have hb := two_term_binomial p m k
    rw [← hk] at hb
    have hle : p ^ m ≤ m * m * p ^ k := by
      calc p ^ m = p * p ^ k := by rw [hk]; ring
        _ ≤ (m * m) * p ^ k := Nat.mul_le_mul_right _ hmp
    omega
  have hppos : 0 < p ^ m := pow_pos hp m
  nlinarith [h1, h2, h3, hppos]

/-! ## The `ρ` success bound at `t = 2m` nodes -/

/-- **The birthday success bound.**  Let `N = p·q` with `5 ≤ p`, let `t = 2m` with
`p ≤ m²` (that is, `t ≈ 2√p` nodes) and let the node budget be small compared to
the large prime, `t² ≤ q`.  Then the pair test succeeds on at least `30 %` of all
value streams.  Contrast `Dive.trial_division_scaling`, where the *same* budget
gives success below `1/2` only because it is far below the `p/4` that a value
test requires. -/
theorem rho_birthday_success {p q m t : ℕ} (hp : p.Prime) (hq : q.Prime) (hp5 : 5 ≤ p)
    (hmp : p ≤ m * m) (ht : t = 2 * m) (htq : t * t ≤ q) :
    3 * (p * q) ^ t ≤ 10 * (rhoHitSet p q t).card := by
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  have hq2 := hq.two_le
  set N := p * q with hN
  have hNpos : 0 < N := Nat.mul_pos hp0 hq0
  -- the two parts of the complement
  have hsplit : (rhoHitSet p q t).card
      + ((samples N t).filter (fun f => ¬ RhoHit p f)).card = N ^ t := by
    have h := Finset.card_filter_add_card_filter_not (s := samples N t)
      (p := fun f => RhoHit p f)
    rw [card_samples] at h
    exact h
  have hcomp := card_noRho_le p q t hp0 hq0
  rw [← hN] at hcomp
  -- the descending-factorial part is at most half of everything
  have hA : 2 * (p.descFactorial t * q ^ t) ≤ N ^ t := by
    have hb : 2 * p.descFactorial t ≤ p ^ t := by
      rw [ht]; exact birthday_desc (by omega) hmp
    calc 2 * (p.descFactorial t * q ^ t) = (2 * p.descFactorial t) * q ^ t := by ring
      _ ≤ p ^ t * q ^ t := Nat.mul_le_mul_right _ hb
      _ = N ^ t := by rw [hN, mul_pow]
  -- the repeated-value part is at most a `1/p` share
  have hB : 5 * ((t * t - t) * N ^ (t - 1)) ≤ N ^ t := by
    rcases Nat.eq_zero_or_pos t with rfl | ht0
    · simp
    have hpow : N * N ^ (t - 1) = N ^ t := by
      rw [← pow_succ']; congr 1; omega
    calc 5 * ((t * t - t) * N ^ (t - 1)) ≤ p * (q * N ^ (t - 1)) := by
          have h1 : t * t - t ≤ q := le_trans (Nat.sub_le _ _) htq
          calc 5 * ((t * t - t) * N ^ (t - 1)) = 5 * (t * t - t) * N ^ (t - 1) := by ring
            _ ≤ p * q * N ^ (t - 1) := by
                exact Nat.mul_le_mul_right _ (Nat.mul_le_mul hp5 h1)
            _ = p * (q * N ^ (t - 1)) := by ring
      _ = N * N ^ (t - 1) := by rw [hN]; ring
      _ = N ^ t := hpow
  omega

/-! ## The separation -/

/-- **`ρ` dominates the dive at matched compute.**  Under a single set of
hypotheses — `N = p·q`, `5 ≤ p ≤ q`, budget `t = 2m` with `p ≤ m²` (so
`t ≍ 2√p`), `4t < p` and `t² ≤ q` — *every* value-testing schedule `S` succeeds
on fewer than half of the streams, while the pair test succeeds on at least three
tenths of them.  The two exponents are `p` versus `√p`: the projected tree's
`α = 1` dive can never compete with a collision search. -/
theorem rho_dominates_dive {p q m t : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hle : p ≤ q) (hp5 : 5 ≤ p) (hmp : p ≤ m * m) (ht : t = 2 * m) (htq : t * t ≤ q)
    (hbudget : 4 * t < p) (S : Finset (Fin t)) :
    2 * (hitSet (p * q) t S).card < (p * q) ^ t ∧
      3 * (p * q) ^ t ≤ 10 * (rhoHitSet p q t).card := by
  refine ⟨trial_division_scaling hp hq hpq hle S ?_,
    rho_birthday_success hp hq hp5 hmp ht htq⟩
  have := card_le_of_card_S t S
  omega

/-- A concrete instance: `N = 101 · 487`, budget `t = 22` nodes.  Every gcd-dive
schedule succeeds on under half the streams, the pair test on at least `30 %`. -/
theorem rho_dominates_dive_concrete (S : Finset (Fin 22)) :
    2 * (hitSet (101 * 487) 22 S).card < (101 * 487) ^ 22 ∧
      3 * (101 * 487) ^ 22 ≤ 10 * (rhoHitSet 101 487 22).card := by
  refine rho_dominates_dive (m := 11) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) S

end Dive
end BerggrenModular