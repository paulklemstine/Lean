/-
# The 3SUM / Birthday-Bound Hierarchy for Semiprime Factoring

This file formalises two independent things and then glues them together.

## Part I — the *factor reveal*

If `N = p * q` is a semiprime and `s` is any integer with `p ∣ s` but `q ∤ s`,
then `gcd s N = p`: the hidden factor is revealed exactly.  Applied to a 3SUM
witness `s = a + b + c` this is the "3SUM mod p reveals a factor" observation.
We prove the *complete* classification of `gcd s (p*q)` (four cases) and the
iff-characterisation `gcd s N = p ↔ p ∣ s ∧ ¬ q ∣ s`.

## Part II — the arity-uniform birthday bound

All the collision-based methods (`k` singular-moduli evaluations, `k²` sumset
pairs, `k³` 3SUM triples) are the *same* pigeonhole statement at arity
`r = 1, 2, 3`.  We prove a matching pair of bounds for every arity `r`:

* **sufficiency** `p < C(k,r)` forces a collision (`exists_collision_of_choose_gt`);
* **necessity**  `C(k,r) ≤ p` admits a collision-free instance
  (`threshold_optimal`), hence a *guaranteed* collision costs `> p` enumerated
  tuples, whatever the arity (`guarantee_forces_cost`).

So the arity only changes how the enumerated tuples are packaged: the search set
shrinks (`p < k^r`, so `k > p^{1/r}` — the exponent `1/2 → 1/3` improvement),
but the **net cost stays `> p ≥ √N`** (`sqrt_barrier`).  That is the barrier.

Everything is `sorry`-free.
-/

import Mathlib

namespace ThreeSumBirthday

/-! ## Part I : the 3SUM mod-p factor reveal -/

section FactorReveal

variable {p q s : ℕ}

/-- If `p ∣ s` and `q ∤ s`, for distinct primes `p, q`, then `gcd s (p*q) = p`.
This is the exact "factor reveal" step. -/
theorem gcd_eq_left_of_dvd_of_not_dvd (hp : p.Prime) (hq : q.Prime)
    (hps : p ∣ s) (hqs : ¬ q ∣ s) : Nat.gcd s (p * q) = p := by
  have hdvd : p ∣ Nat.gcd s (p * q) := Nat.dvd_gcd hps ⟨q, rfl⟩
  obtain ⟨t, ht⟩ := hdvd
  have h1 : Nat.gcd s (p * q) ∣ p * q := Nat.gcd_dvd_right _ _
  rw [ht] at h1
  have ht' : t ∣ q := (mul_dvd_mul_iff_left (a := p) hp.pos.ne').1 h1
  rcases (hq.eq_one_or_self_of_dvd t ht') with h | h
  · rw [ht, h, mul_one]
  · exfalso
    apply hqs
    have hq' : q ∣ Nat.gcd s (p * q) := by
      rw [ht, h]; exact ⟨p, mul_comm p q⟩
    exact hq'.trans (Nat.gcd_dvd_left _ _)

/-- The symmetric statement: `q ∣ s`, `p ∤ s` reveals `q`. -/
theorem gcd_eq_right_of_dvd_of_not_dvd (hp : p.Prime) (hq : q.Prime)
    (hqs : q ∣ s) (hps : ¬ p ∣ s) : Nat.gcd s (p * q) = q := by
  rw [mul_comm]
  exact gcd_eq_left_of_dvd_of_not_dvd hq hp hqs hps

/-- Complete classification of `gcd s (p*q)` for distinct primes `p ≠ q`:
it is `1`, `p`, `q` or `p*q` according to which primes divide `s`. -/
theorem gcd_semiprime_classification (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Nat.gcd s (p * q) =
      if p ∣ s then (if q ∣ s then p * q else p) else (if q ∣ s then q else 1) := by
  by_cases hps : p ∣ s <;> by_cases hqs : q ∣ s <;> simp [hps, hqs]
  · -- both divide: `p*q ∣ s`
    have : p * q ∣ s := (Nat.Coprime.mul_dvd_of_dvd_of_dvd
      ((Nat.coprime_primes hp hq).2 hpq) hps hqs)
    exact Nat.gcd_eq_right this
  · exact gcd_eq_left_of_dvd_of_not_dvd hp hq hps hqs
  · exact gcd_eq_right_of_dvd_of_not_dvd hp hq hqs hps
  · -- neither divides: the gcd is a divisor of `p*q` divisible by no prime
    have hd : Nat.gcd s (p * q) ∣ p * q := Nat.gcd_dvd_right _ _
    by_contra hne
    obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd hne
    have hrs : r ∣ s := hrd.trans (Nat.gcd_dvd_left _ _)
    have hrpq : r ∣ p * q := hrd.trans hd
    rcases (Nat.Prime.dvd_mul hr).1 hrpq with h | h
    · exact hps (((Nat.prime_dvd_prime_iff_eq hr hp).1 h) ▸ hrs)
    · exact hqs (((Nat.prime_dvd_prime_iff_eq hr hq).1 h) ▸ hrs)

/-- The reveal is an exact characterisation, not just a sufficient condition. -/
theorem gcd_eq_left_iff (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Nat.gcd s (p * q) = p ↔ (p ∣ s ∧ ¬ q ∣ s) := by
  constructor
  · intro h
    have hps : p ∣ s := h ▸ Nat.gcd_dvd_left s (p * q)
    refine ⟨hps, fun hqs => ?_⟩
    have hpq' : p * q ∣ s :=
      Nat.Coprime.mul_dvd_of_dvd_of_dvd ((Nat.coprime_primes hp hq).2 hpq) hps hqs
    have hg : Nat.gcd s (p * q) = p * q := Nat.gcd_eq_right hpq'
    rw [h] at hg
    have h1 : 1 < q := hq.one_lt
    nlinarith [hp.pos]
  · rintro ⟨h1, h2⟩
    exact gcd_eq_left_of_dvd_of_not_dvd hp hq h1 h2

/-- **3SUM mod-p factor reveal.** A triple whose sum vanishes mod `p` but not
mod `q` yields the factor `p` of `N = p*q` by a single gcd. -/
theorem threeSum_reveals_factor (hp : p.Prime) (hq : q.Prime)
    {a b c : ℕ} (hps : p ∣ (a + b + c)) (hqs : ¬ q ∣ (a + b + c)) :
    Nat.gcd (a + b + c) (p * q) = p :=
  gcd_eq_left_of_dvd_of_not_dvd hp hq hps hqs

/-- The revealed divisor is a *proper nontrivial* factor of `N`. -/
theorem threeSum_reveals_proper_factor (hp : p.Prime) (hq : q.Prime)
    {a b c : ℕ} (hps : p ∣ (a + b + c)) (hqs : ¬ q ∣ (a + b + c)) :
    1 < Nat.gcd (a + b + c) (p * q) ∧ Nat.gcd (a + b + c) (p * q) < p * q := by
  rw [threeSum_reveals_factor hp hq hps hqs]
  refine ⟨hp.one_lt, ?_⟩
  have := hq.one_lt
  nlinarith [hp.pos]

end FactorReveal

/-! ### Verified instance: `N = 143 = 11 * 13`

We enumerate all triples `1 ≤ a < b < c ≤ 11` and count those whose sum is
divisible by `11` (mod-`p`-only) and those divisible by `143` (mod-both). -/

section Instance143

/-- All triples `1 ≤ a < b < c ≤ 11`. -/
def triples11 : List (ℕ × ℕ × ℕ) :=
  ((List.range' 1 11).flatMap fun a =>
    (List.range' 1 11).flatMap fun b =>
      (List.range' 1 11).map fun c => (a, b, c)).filter
    (fun t => decide (t.1 < t.2.1 ∧ t.2.1 < t.2.2))

/-- Triples with `11 ∣ a+b+c`. -/
def modPTriples143 : List (ℕ × ℕ × ℕ) :=
  triples11.filter (fun t => (t.1 + t.2.1 + t.2.2) % 11 == 0)

/-- Triples with `143 ∣ a+b+c` (i.e. mod-`p` *and* mod-`q`). -/
def modBothTriples143 : List (ℕ × ℕ × ℕ) :=
  triples11.filter (fun t => (t.1 + t.2.1 + t.2.2) % 143 == 0)

theorem count_modP_143 : modPTriples143.length = 15 := by decide

theorem count_modBoth_143 : modBothTriples143.length = 0 := by decide

/-- Every mod-`p`-only triple in the enumeration reveals the factor `11`. -/
theorem all_modP_triples_reveal :
    ∀ t ∈ modPTriples143, Nat.gcd (t.1 + t.2.1 + t.2.2) 143 = 11 := by decide

/-- A concrete witness of the reveal: `1 + 4 + 6 = 11`, `gcd 11 143 = 11`. -/
theorem example_reveal : Nat.gcd (1 + 4 + 6) 143 = 11 := by
  have h11 : Nat.Prime 11 := by norm_num
  have h13 : Nat.Prime 13 := by norm_num
  have : (143 : ℕ) = 11 * 13 := by norm_num
  rw [this]
  exact threeSum_reveals_factor h11 h13 (by norm_num) (by decide)

end Instance143

/-! ## Part II : the arity-uniform birthday bound

We model a "collision search of arity `r` over a set `S`" as the family
`S.powersetCard r` of `r`-element subsets, each evaluated by some residue
function into `ZMod p`.  The canonical evaluation is the subset sum mod `p`. -/

section Birthday

variable {p : ℕ}

/-- **Sufficiency (pigeonhole).** If the number `C(|S|, r)` of enumerated
`r`-subsets exceeds `p`, two distinct `r`-subsets have equal sum mod `p`.
Arity `r = 1` is the singular-moduli row, `r = 2` the sumset row, `r = 3` the
3SUM row of the hierarchy table. -/
theorem exists_collision_of_choose_gt (hp : 0 < p) (S : Finset ℕ) (r : ℕ)
    (h : p < S.card.choose r) :
    ∃ A ∈ S.powersetCard r, ∃ B ∈ S.powersetCard r,
      A ≠ B ∧ (A.sum id) % p = (B.sum id) % p := by
  have hcard : (Finset.range p).card < (S.powersetCard r).card := by
    simpa [Finset.card_powersetCard] using h
  have hmaps : Set.MapsTo (fun A : Finset ℕ => (A.sum id) % p)
      ↑(S.powersetCard r) ↑(Finset.range p) := by
    intro A _
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.mod_lt _ hp
  obtain ⟨A, hA, B, hB, hne, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  exact ⟨A, hA, B, hB, hne, heq⟩

/-- **Necessity (adversary).** If at most `p` tuples are enumerated, there is an
evaluation with no collision at all: the pigeonhole threshold `p+1` is optimal. -/
theorem threshold_optimal (hp : 0 < p) (T : Finset (Finset ℕ)) (h : T.card ≤ p) :
    ∃ v : Finset ℕ → ZMod p, ∀ A ∈ T, ∀ B ∈ T, v A = v B → A = B := by
  haveI : NeZero p := ⟨hp.ne'⟩
  have hc : Fintype.card {x // x ∈ T} ≤ Fintype.card (ZMod p) := by
    simpa [Fintype.card_coe, ZMod.card] using h
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hc
  refine ⟨fun A => if hA : A ∈ T then e ⟨A, hA⟩ else 0, ?_⟩
  intro A hA B hB hv
  simp only [dif_pos hA, dif_pos hB] at hv
  exact congrArg Subtype.val (e.injective hv)

/-- **Cost lower bound, uniform in the arity.**  If an arity-`r` collision search
over `S` is *guaranteed* to succeed against every evaluation, then it must
enumerate more than `p` tuples — no matter how large the arity `r` is. -/
theorem guarantee_forces_cost (hp : 0 < p) (S : Finset ℕ) (r : ℕ)
    (hguar : ∀ v : Finset ℕ → ZMod p, ∃ A ∈ S.powersetCard r,
      ∃ B ∈ S.powersetCard r, A ≠ B ∧ v A = v B) :
    p < S.card.choose r := by
  by_contra hle
  push_neg at hle
  have hcard : (S.powersetCard r).card ≤ p := by
    simpa [Finset.card_powersetCard] using hle
  obtain ⟨v, hv⟩ := threshold_optimal hp _ hcard
  obtain ⟨A, hA, B, hB, hne, heq⟩ := hguar v
  exact hne (hv A hA B hB heq)

/-- Sufficiency and necessity match exactly: an arity-`r` search over `S`
guarantees a collision **iff** it enumerates more than `p` tuples. -/
theorem guarantee_iff_cost (hp : 0 < p) (S : Finset ℕ) (r : ℕ) :
    (∀ v : Finset ℕ → ZMod p, ∃ A ∈ S.powersetCard r, ∃ B ∈ S.powersetCard r,
        A ≠ B ∧ v A = v B) ↔ p < S.card.choose r := by
  haveI : NeZero p := ⟨hp.ne'⟩
  refine ⟨guarantee_forces_cost hp S r, fun h v => ?_⟩
  -- the "hardest" evaluation is no easier than the sum evaluation
  have hcard : (Finset.univ : Finset (ZMod p)).card < (S.powersetCard r).card := by
    simpa [Finset.card_powersetCard, ZMod.card] using h
  obtain ⟨A, hA, B, hB, hne, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to (f := v) hcard
      (fun A _ => Finset.mem_coe.2 (Finset.mem_univ _))
  exact ⟨A, hA, B, hB, hne, heq⟩

end Birthday

/-! ### The hierarchy: the exponent improves, the net cost does not -/

section Hierarchy

variable {p k : ℕ}

/-- The search-set size satisfies `k^r > p`, i.e. `k > p^{1/r}`: this is the
exponent improvement `1/2 → 1/3 → …` as the arity grows. -/
theorem search_space_pow_gt (r : ℕ) (h : p < k.choose r) : p < k ^ r :=
  lt_of_lt_of_le h (Nat.choose_le_pow k r)

/-- Arity 2 (sumset `a+b ≡ c+d`): a guaranteed collision needs `k² > 2p`,
i.e. `k ≳ √(2p)`. -/
theorem sumset_size_bound (h : p < k.choose 2) : 2 * p < k * k := by
  rw [Nat.choose_two_right] at h
  have hk : k * (k - 1) / 2 * 2 ≤ k * (k - 1) := Nat.div_mul_le_self _ _
  have h2 : 2 * p < k * (k - 1) := by omega
  have : k * (k - 1) ≤ k * k := Nat.mul_le_mul_left _ (Nat.sub_le _ _)
  omega

/-- `6 · C(n,3) ≤ n³`, proved by induction via Pascal's rule. -/
theorem choose_three_mul_six_le : ∀ n : ℕ, n.choose 3 * 6 ≤ n * n * n := by
  intro n
  induction n with
  | zero => simp
  | succ m ih =>
    have h2 : m.choose 2 * 2 ≤ m * m := by
      rw [Nat.choose_two_right]
      have hd := Nat.div_mul_le_self (m * (m - 1)) 2
      have hm : m * (m - 1) ≤ m * m := Nat.mul_le_mul_left _ (Nat.sub_le _ _)
      omega
    rw [Nat.choose_succ_succ' m 2, show (2 + 1) = 3 from rfl]
    have hexp : (m + 1) * (m + 1) * (m + 1) = m * m * m + 3 * (m * m) + 3 * m + 1 := by ring
    omega

/-- Arity 3 (3SUM `a+b+c ≡ 0`): a guaranteed collision needs `k³ > 6p`,
i.e. `k ≳ (6p)^{1/3}` — a genuinely smaller search set than arity 2. -/
theorem threeSum_size_bound (h : p < k.choose 3) : 6 * p < k * k * k := by
  have h3 := choose_three_mul_six_le k
  omega

/-- **Higher arity never hurts**: whenever the arity-`r` search over a `k`-set
guarantees a collision and `r < k/2`, so does the arity-`(r+1)` search.
This orders the hierarchy: evaluations ⊆ sumset ⊆ 3SUM ⊆ … -/
theorem arity_monotone {r : ℕ} (hr : r < k / 2) (h : p < k.choose r) :
    p < k.choose (r + 1) :=
  lt_of_lt_of_le h (Nat.choose_le_succ_of_lt_half_left hr)

/-- **The barrier.**  Any guaranteed collision search costs more than `p`
enumerated tuples, and for a semiprime `N = p*q` with `q ≤ p` this is more
than `√N`.  The bound is independent of the arity `r`, so the whole hierarchy
(evaluations / sumset / 3SUM / …) sits at the same `√N` wall. -/
theorem sqrt_barrier {p q C : ℕ} (hqp : q ≤ p) (h : p < C) : Nat.sqrt (p * q) < C := by
  have h1 : p * q ≤ p * p := Nat.mul_le_mul_left _ hqp
  have h2 : Nat.sqrt (p * q) ≤ Nat.sqrt (p * p) := Nat.sqrt_le_sqrt h1
  rw [Nat.sqrt_eq] at h2
  omega

/-- The barrier in the form used in the hierarchy table: for **every** arity `r`,
a guaranteed arity-`r` collision search modulo `p` over a set `S` costs
`> √N` tuples, where `N = p*q` is the semiprime and `q ≤ p`. -/
theorem hierarchy_sqrt_barrier {p q : ℕ} (hp : 0 < p) (hqp : q ≤ p)
    (S : Finset ℕ) (r : ℕ)
    (hguar : ∀ v : Finset ℕ → ZMod p, ∃ A ∈ S.powersetCard r,
      ∃ B ∈ S.powersetCard r, A ≠ B ∧ v A = v B) :
    Nat.sqrt (p * q) < S.card.choose r :=
  sqrt_barrier hqp (guarantee_forces_cost hp S r hguar)

end Hierarchy

/-! ## Part III : gluing the two halves — collision ⟹ factor -/

section Pipeline

variable {p q : ℕ}

/-- A collision `x ≡ y (mod p)` with `y ≤ x` and `q ∤ (x - y)` reveals `p`. -/
theorem factor_of_collision (hp : p.Prime) (hq : q.Prime)
    {x y : ℕ} (hyx : y ≤ x) (hcol : x % p = y % p) (hqs : ¬ q ∣ (x - y)) :
    Nat.gcd (x - y) (p * q) = p := by
  have hdvd : p ∣ x - y := (Nat.modEq_iff_dvd' hyx).1 hcol.symm
  exact gcd_eq_left_of_dvd_of_not_dvd hp hq hdvd hqs

/-- **The full pipeline, at every arity `r`.**  Enumerate more than `p`
`r`-subsets of `S`; a sum collision mod `p` exists; provided the (generic)
non-degeneracy condition `q ∤ (difference)` holds, the gcd of the difference
with `N = p*q` is exactly `p`.  For `r = 3` this is the 3SUM factor reveal. -/
theorem collision_search_factors (hp : p.Prime) (hq : q.Prime)
    (S : Finset ℕ) (r : ℕ) (h : p < S.card.choose r) :
    ∃ A ∈ S.powersetCard r, ∃ B ∈ S.powersetCard r, A ≠ B ∧
      p ∣ (max (A.sum id) (B.sum id) - min (A.sum id) (B.sum id)) ∧
      (¬ q ∣ (max (A.sum id) (B.sum id) - min (A.sum id) (B.sum id)) →
        Nat.gcd (max (A.sum id) (B.sum id) - min (A.sum id) (B.sum id)) (p * q) = p) := by
  obtain ⟨A, hA, B, hB, hne, heq⟩ := exists_collision_of_choose_gt (p := p) hp.pos S r h
  refine ⟨A, hA, B, hB, hne, ?_, ?_⟩
  · rcases le_total (A.sum id) (B.sum id) with hle | hle
    · rw [max_eq_right hle, min_eq_left hle]
      exact (Nat.modEq_iff_dvd' hle).1 heq
    · rw [max_eq_left hle, min_eq_right hle]
      exact (Nat.modEq_iff_dvd' hle).1 heq.symm
  · intro hq'
    refine gcd_eq_left_of_dvd_of_not_dvd hp hq ?_ hq'
    rcases le_total (A.sum id) (B.sum id) with hle | hle
    · rw [max_eq_right hle, min_eq_left hle]
      exact (Nat.modEq_iff_dvd' hle).1 heq
    · rw [max_eq_left hle, min_eq_right hle]
      exact (Nat.modEq_iff_dvd' hle).1 heq.symm

end Pipeline

end ThreeSumBirthday