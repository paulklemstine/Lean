import Mathlib
import Novelty.GCDMomentTraceWitness
import Novelty.GCDMomentPairInversion
import Novelty.GCDMomentMultiplicative
import Novelty.GCDMomentRefinementOrder

/-!
# The factorisation lattice of a gcd moment: both extremes are attained *uniquely*

This is the fourth cycle of the gcd-moment project
(`Novelty.GCDMomentTraceWitness`, `Novelty.GCDMomentPairInversion`,
`Novelty.GCDMomentHigherInversion`, `Novelty.GCDMomentMultiplicative`,
`Novelty.GCDMomentRefinementOrder`).

Cycle 3 proved that the moment predicted by *any* factorisation `n = a_1 ⋯ a_r` into parts
`a_i ≥ 2`, namely

`E_k(a_1,…,a_r) = ∏_i (a_i^k + a_i − 1)`  (`factorisationEuler`),

lies in the bracket `[n^k + n − 1, Π_k(n)]`, where `Π_k(n)` is the value at the prime
factorisation (`primeProd`).  What was missing was *uniqueness* at the two ends.  This file
supplies it and draws the consequence for the inversion problem:

* `factorisationEuler_all_prime` — a factorisation into primes always predicts `Π_k(n)`.
* `factorisationEuler_lt_primeProd_of_mem_not_prime` — one composite part already makes the
  prediction *strictly* smaller than `Π_k(n)`.
* `factorisationEuler_eq_primeProd_iff_all_prime` — **the prime factorisation is the unique
  maximiser** of the predicted moment.
* `local_le_factorisationEuler`, `local_lt_factorisationEuler` — the natural-number form of the
  lower end, with strictness as soon as there are two parts: **the trivial factorisation `[n]` is
  the unique minimiser.**
* `collision_of_all_prime`, `collision_of_singleton` — consequently *no* collision of predicted
  moments can involve an extremal factorisation: if two factorisations of the same modulus
  predict the same moment and one of them is the prime factorisation (resp. the trivial
  factorisation), they agree up to order.
* `length_le_cardFactors`, `all_prime_of_cardFactors_le_length` — the combinatorial input: a
  factorisation into parts `≥ 2` has at most `Ω(n)` parts, with equality exactly when every part
  is prime.
* `no_collision_of_cardFactors_le_two` — **the capstone**: for every `k ≥ 1`, if `Ω(n) ≤ 2` then
  the predicted moment determines the factorisation up to order.  In particular
  `no_collision_semiprime`: on the semiprime moduli that the factoring question is about, *every*
  moment — including the ambiguous `k = 2` — is injective on factorisations.  Every collision
  (e.g. the `k = 2` collisions `2·14 = 4·7` at `N = 28` and `2·18 = 3·12` at `N = 36`) therefore
  needs `Ω(N) ≥ 3` and a composite part on *both* sides, which is exactly what those two
  examples show.
-/

namespace GCDMoment

open ArithmeticFunction

/-! ### Arithmetic of the natural-number Euler product -/

/-- A single local factor of a part `≥ 2` is at least `3`. -/
lemma three_le_part {a k : ℕ} (ha : 2 ≤ a) (hk : 1 ≤ k) : 3 ≤ a ^ k + a - 1 := by
  have : a ≤ a ^ k := Nat.le_self_pow (by omega) a
  omega

/-- A local factor of a part `≥ 1` is at least `1`. -/
lemma one_le_part {a k : ℕ} (ha : 1 ≤ a) (hk : 1 ≤ k) : 1 ≤ a ^ k + a - 1 := by
  have : a ≤ a ^ k := Nat.le_self_pow (by omega) a
  omega

@[simp] lemma factorisationEuler_nil (k : ℕ) : factorisationEuler k [] = 1 := by
  simp [factorisationEuler]

lemma factorisationEuler_cons (k a : ℕ) (t : List ℕ) :
    factorisationEuler k (a :: t) = (a ^ k + a - 1) * factorisationEuler k t := by
  simp [factorisationEuler]

lemma factorisationEuler_append (k : ℕ) (s t : List ℕ) :
    factorisationEuler k (s ++ t) = factorisationEuler k s * factorisationEuler k t := by
  simp [factorisationEuler, List.map_append, List.prod_append]

lemma factorisationEuler_pos {k : ℕ} (hk : 1 ≤ k) :
    ∀ {l : List ℕ}, (∀ a ∈ l, 1 ≤ a) → 0 < factorisationEuler k l
  | [], _ => by simp
  | (a :: t), h => by
      have ha : 1 ≤ a := h a (by simp)
      have ih : 0 < factorisationEuler k t :=
        factorisationEuler_pos hk (fun x hx => h x (by simp [hx]))
      have := one_le_part (a := a) (k := k) ha hk
      rw [factorisationEuler_cons]
      exact Nat.mul_pos (by omega) ih

/-! ### The lower end of the bracket, in `ℕ` -/

/-- Splitting one part strictly raises the predicted moment (natural-number form of
`eulerLocal_refine`). -/
lemma local_refine_nat {u v k : ℕ} (hu : 2 ≤ u) (hv : 2 ≤ v) (hk : 1 ≤ k) :
    (u * v) ^ k + u * v - 1 < (u ^ k + u - 1) * (v ^ k + v - 1) := by
  have h := eulerLocal_refine (u := (u : ℤ)) (v := (v : ℤ))
    (by exact_mod_cast hu) (by exact_mod_cast hv) hk
  simp only [eulerLocal] at h
  have hu1 : 1 ≤ u ^ k + u := by
    have : 1 ≤ u ^ k := Nat.one_le_pow _ _ (by omega); omega
  have hv1 : 1 ≤ v ^ k + v := by
    have : 1 ≤ v ^ k := Nat.one_le_pow _ _ (by omega); omega
  have huv1 : 1 ≤ (u * v) ^ k + u * v := by
    have : 1 ≤ (u * v) ^ k := Nat.one_le_pow _ _ (by positivity); omega
  zify [hu1, hv1, huv1]
  linarith [h]

/-- **The lower end of the bracket.**  Any factorisation into parts `≥ 2` predicts at least the
local factor of the modulus. -/
theorem local_le_factorisationEuler {k : ℕ} (hk : 1 ≤ k) :
    ∀ (l : List ℕ), l ≠ [] → (∀ a ∈ l, 2 ≤ a) →
      l.prod ^ k + l.prod - 1 ≤ factorisationEuler k l
  | [], h, _ => absurd rfl h
  | [a], _, _ => by simp [factorisationEuler]
  | (a :: b :: t), _, h => by
      have ha : 2 ≤ a := h a (by simp)
      have hrest : 2 ≤ (b :: t).prod := by
        have hb : 2 ≤ b := h b (by simp)
        have : 1 ≤ t.prod := List.one_le_prod (fun x hx => by have := h x (by simp [hx]); omega)
        rw [List.prod_cons]
        calc 2 = 2 * 1 := by ring
          _ ≤ b * t.prod := Nat.mul_le_mul hb this
      have ih : (b :: t).prod ^ k + (b :: t).prod - 1 ≤ factorisationEuler k (b :: t) :=
        local_le_factorisationEuler hk (b :: t) (by simp) (fun x hx => h x (by simp [hx]))
      have hstep := local_refine_nat ha hrest hk
      have hpos : 0 < a ^ k + a - 1 := by have := three_le_part ha hk; omega
      calc (a :: b :: t).prod ^ k + (a :: b :: t).prod - 1
          = (a * (b :: t).prod) ^ k + a * (b :: t).prod - 1 := by rw [List.prod_cons]
        _ ≤ (a ^ k + a - 1) * ((b :: t).prod ^ k + (b :: t).prod - 1) := le_of_lt hstep
        _ ≤ (a ^ k + a - 1) * factorisationEuler k (b :: t) := Nat.mul_le_mul_left _ ih
        _ = factorisationEuler k (a :: b :: t) := (factorisationEuler_cons _ _ _).symm

/-- **The trivial factorisation is the unique minimiser.**  As soon as a factorisation has two
parts, its predicted moment strictly exceeds the local factor of the modulus. -/
theorem local_lt_factorisationEuler {k : ℕ} (hk : 1 ≤ k) (a : ℕ) (t : List ℕ) (hne : t ≠ [])
    (h : ∀ x ∈ a :: t, 2 ≤ x) :
    (a :: t).prod ^ k + (a :: t).prod - 1 < factorisationEuler k (a :: t) := by
  have ha : 2 ≤ a := h a (by simp)
  have hrest : 2 ≤ t.prod := by
    obtain ⟨b, s, rfl⟩ : ∃ b s, t = b :: s := by
      cases t with
      | nil => exact absurd rfl hne
      | cons b s => exact ⟨b, s, rfl⟩
    have hb : 2 ≤ b := h b (by simp)
    have : 1 ≤ s.prod := List.one_le_prod (fun x hx => by have := h x (by simp [hx]); omega)
    rw [List.prod_cons]
    calc 2 = 2 * 1 := by ring
      _ ≤ b * s.prod := Nat.mul_le_mul hb this
  have ih : t.prod ^ k + t.prod - 1 ≤ factorisationEuler k t :=
    local_le_factorisationEuler hk t hne (fun x hx => h x (by simp [hx]))
  have hstep := local_refine_nat ha hrest hk
  have hpos : 0 < a ^ k + a - 1 := by have := three_le_part ha hk; omega
  calc (a :: t).prod ^ k + (a :: t).prod - 1
      = (a * t.prod) ^ k + a * t.prod - 1 := by rw [List.prod_cons]
    _ < (a ^ k + a - 1) * (t.prod ^ k + t.prod - 1) := hstep
    _ ≤ (a ^ k + a - 1) * factorisationEuler k t := Nat.mul_le_mul_left _ ih
    _ = factorisationEuler k (a :: t) := (factorisationEuler_cons _ _ _).symm

/-! ### The upper end of the bracket: uniqueness of the maximiser -/

/-- A factorisation into primes predicts exactly `Π_k(n)`. -/
theorem factorisationEuler_all_prime (k : ℕ) :
    ∀ (l : List ℕ), (∀ a ∈ l, a.Prime) → factorisationEuler k l = primeProd k l.prod
  | [], _ => by simp
  | (a :: t), h => by
      have ha : a.Prime := h a (by simp)
      have ht : ∀ x ∈ t, x.Prime := fun x hx => h x (by simp [hx])
      have hprod : 0 < t.prod := List.prod_pos (fun x hx => (ht x hx).pos)
      have ih : factorisationEuler k t = primeProd k t.prod := factorisationEuler_all_prime k t ht
      rw [factorisationEuler_cons, ih, List.prod_cons, primeProd_mul ha.pos.ne' hprod.ne',
        primeProd_prime ha, gcdMoment_prime ha]

/-- A single composite part strictly lowers the prediction below the maximum. -/
theorem factorisationEuler_lt_primeProd_of_mem_not_prime {k : ℕ} (hk : 1 ≤ k) {l : List ℕ}
    (h2 : ∀ a ∈ l, 2 ≤ a) {a : ℕ} (ha : a ∈ l) (hap : ¬ a.Prime) :
    factorisationEuler k l < primeProd k l.prod := by
  obtain ⟨s, t, rfl⟩ := List.append_of_mem ha
  have h2a : 2 ≤ a := h2 a (by simp)
  have hmem : ∀ x ∈ s ++ a :: t, 2 ≤ x := h2
  have h2s : ∀ x ∈ s, 2 ≤ x := fun x hx => hmem x (by simp [hx])
  have h2t : ∀ x ∈ t, 2 ≤ x := fun x hx => hmem x (by simp [hx])
  have hsp : 0 < s.prod := List.prod_pos (fun x hx => by have := h2s x hx; omega)
  have htp : 0 < t.prod := List.prod_pos (fun x hx => by have := h2t x hx; omega)
  -- the composite part is strictly below its own prime product
  have hstrict : a ^ k + a - 1 < primeProd k a := by
    have h1 := gcdMoment_gt_local_of_not_prime h2a hap hk
    have h2' := gcdMoment_le_primeProd hk (n := a) (by omega)
    omega
  have hs : factorisationEuler k s ≤ primeProd k s.prod :=
    factorisationEuler_le_primeProd hk s (fun x hx => by have := h2s x hx; omega)
  have ht : factorisationEuler k t ≤ primeProd k t.prod :=
    factorisationEuler_le_primeProd hk t (fun x hx => by have := h2t x hx; omega)
  have hsp' : 0 < factorisationEuler k s :=
    factorisationEuler_pos hk (fun x hx => by have := h2s x hx; omega)
  have htp' : 0 < factorisationEuler k t :=
    factorisationEuler_pos hk (fun x hx => by have := h2t x hx; omega)
  have hkey : factorisationEuler k s * ((a ^ k + a - 1) * factorisationEuler k t)
      < primeProd k s.prod * (primeProd k a * primeProd k t.prod) := by
    have h1 : (a ^ k + a - 1) * factorisationEuler k t < primeProd k a * primeProd k t.prod :=
      Nat.mul_lt_mul_of_lt_of_le hstrict ht (primeProd_pos t.prod k)
    exact Nat.mul_lt_mul_of_le_of_lt hs h1 (primeProd_pos s.prod k)
  have hprodeq : (s ++ a :: t).prod = s.prod * (a * t.prod) := by
    rw [List.prod_append, List.prod_cons]
  rw [factorisationEuler_append, factorisationEuler_cons, hprodeq,
    primeProd_mul hsp.ne' (by positivity) k, primeProd_mul (by omega) htp.ne' k]
  exact hkey

/-- **The prime factorisation is the unique maximiser of the predicted moment.** -/
theorem factorisationEuler_eq_primeProd_iff_all_prime {k : ℕ} (hk : 1 ≤ k) {l : List ℕ}
    (h2 : ∀ a ∈ l, 2 ≤ a) :
    factorisationEuler k l = primeProd k l.prod ↔ ∀ a ∈ l, a.Prime := by
  constructor
  · intro heq a ha
    by_contra hap
    exact absurd heq (factorisationEuler_lt_primeProd_of_mem_not_prime hk h2 ha hap).ne
  · intro h
    exact factorisationEuler_all_prime k l h

/-! ### No collision can involve an extremal factorisation -/

/-- If a factorisation into primes predicts the same moment as another factorisation of the same
modulus, the two agree up to order. -/
theorem collision_of_all_prime {k : ℕ} (hk : 1 ≤ k) {l m : List ℕ} (h2m : ∀ a ∈ m, 2 ≤ a)
    (hl : ∀ a ∈ l, a.Prime) (hprod : l.prod = m.prod)
    (heq : factorisationEuler k l = factorisationEuler k m) : l.Perm m := by
  have h2l : ∀ a ∈ l, 2 ≤ a := fun a ha => (hl a ha).two_le
  have hmax : factorisationEuler k m = primeProd k m.prod := by
    rw [← heq, factorisationEuler_all_prime k l hl, hprod]
  have hmp : ∀ a ∈ m, a.Prime := (factorisationEuler_eq_primeProd_iff_all_prime hk h2m).1 hmax
  have hpl := Nat.primeFactorsList_unique (n := l.prod) rfl hl
  have hpm := Nat.primeFactorsList_unique (n := m.prod) rfl hmp
  rw [hprod] at hpl
  exact hpl.trans hpm.symm

/-- If the trivial factorisation `[n]` predicts the same moment as another factorisation of `n`,
that other factorisation is `[n]` as well. -/
theorem collision_of_singleton {k : ℕ} (hk : 1 ≤ k) {n : ℕ} {l : List ℕ} (hn : 2 ≤ n)
    (h2 : ∀ a ∈ l, 2 ≤ a) (hprod : l.prod = n)
    (heq : factorisationEuler k [n] = factorisationEuler k l) : l = [n] := by
  cases l with
  | nil => simp at hprod; omega
  | cons a t =>
      cases t with
      | nil =>
          simp only [List.prod_cons, List.prod_nil, mul_one] at hprod
          rw [hprod]
      | cons b s =>
          exfalso
          have hlt := local_lt_factorisationEuler hk a (b :: s) (by simp) h2
          rw [hprod] at hlt
          have : factorisationEuler k [n] = n ^ k + n - 1 := by simp [factorisationEuler]
          omega

/-! ### The combinatorics of the number of parts -/

/-- A factorisation into parts `≥ 2` has at most `Ω(n)` parts. -/
lemma length_le_cardFactors :
    ∀ (l : List ℕ), (∀ a ∈ l, 2 ≤ a) → l.length ≤ cardFactors l.prod
  | [], _ => by simp
  | (a :: t), h => by
      have ha : 2 ≤ a := h a (by simp)
      have ht : ∀ x ∈ t, 2 ≤ x := fun x hx => h x (by simp [hx])
      have htp : 0 < t.prod := List.prod_pos (fun x hx => by have := ht x hx; omega)
      have ih : t.length ≤ cardFactors t.prod := length_le_cardFactors t ht
      have h1 : 1 ≤ cardFactors a := by
        rw [cardFactors_apply]
        have : a.primeFactorsList ≠ [] := by
          simp only [ne_eq, Nat.primeFactorsList_eq_nil, not_or]
          omega
        exact List.length_pos_iff.2 this
      rw [List.prod_cons, cardFactors_mul (by omega) htp.ne']
      simp only [List.length_cons]
      omega

/-- Equality in `length_le_cardFactors` forces every part to be prime. -/
lemma all_prime_of_cardFactors_le_length :
    ∀ (l : List ℕ), (∀ a ∈ l, 2 ≤ a) → cardFactors l.prod ≤ l.length → ∀ a ∈ l, a.Prime
  | [], _, _ => by simp
  | (a :: t), h, hle => by
      have ha : 2 ≤ a := h a (by simp)
      have ht : ∀ x ∈ t, 2 ≤ x := fun x hx => h x (by simp [hx])
      have htp : 0 < t.prod := List.prod_pos (fun x hx => by have := ht x hx; omega)
      have hlent : t.length ≤ cardFactors t.prod := length_le_cardFactors t ht
      have h1 : 1 ≤ cardFactors a := by
        rw [cardFactors_apply]
        have : a.primeFactorsList ≠ [] := by
          simp only [ne_eq, Nat.primeFactorsList_eq_nil, not_or]
          omega
        exact List.length_pos_iff.2 this
      rw [List.prod_cons, cardFactors_mul (by omega) htp.ne'] at hle
      simp only [List.length_cons] at hle
      have hA : cardFactors a = 1 := by omega
      have hap : a.Prime := cardFactors_eq_one_iff_prime.1 hA
      have htle : cardFactors t.prod ≤ t.length := by omega
      have := all_prime_of_cardFactors_le_length t ht htle
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx'
      · exact hap
      · exact this x hx'

/-! ### The capstone: at most two prime factors ⟹ no collision at any `k` -/

/-- **No collision below three prime factors.**  For every `k ≥ 1`, if the modulus has at most
two prime factors counted with multiplicity, then the moment predicted by a factorisation
determines that factorisation up to order.  Equivalently: every collision of predicted moments
— such as the second-moment collisions `2·14 = 4·7` (`N = 28`) and `2·18 = 3·12` (`N = 36`) —
needs `Ω(N) ≥ 3`, and (by `collision_of_all_prime` and `collision_of_singleton`) a composite
part on both sides. -/
theorem no_collision_of_cardFactors_le_two {k : ℕ} (hk : 1 ≤ k) {n : ℕ} (hn : 2 ≤ n)
    (hOmega : cardFactors n ≤ 2) {l m : List ℕ} (h2l : ∀ a ∈ l, 2 ≤ a) (h2m : ∀ a ∈ m, 2 ≤ a)
    (hl : l.prod = n) (hm : m.prod = n)
    (heq : factorisationEuler k l = factorisationEuler k m) : l.Perm m := by
  have hlen_l : l.length ≤ 2 := by
    have := length_le_cardFactors l h2l
    rw [hl] at this; omega
  have hlen_m : m.length ≤ 2 := by
    have := length_le_cardFactors m h2m
    rw [hm] at this; omega
  have hl0 : l ≠ [] := by
    intro h; rw [h] at hl; simp at hl; omega
  have hm0 : m ≠ [] := by
    intro h; rw [h] at hm; simp at hm; omega
  -- if either side has a single part, that part is `n` and the other side must match
  by_cases hl1 : l.length = 1
  · obtain ⟨a, rfl⟩ := List.length_eq_one_iff.1 hl1
    have : a = n := by simpa using hl
    subst this
    have := collision_of_singleton hk hn h2m hm heq
    rw [this]
  by_cases hm1 : m.length = 1
  · obtain ⟨a, rfl⟩ := List.length_eq_one_iff.1 hm1
    have : a = n := by simpa using hm
    subst this
    have := collision_of_singleton hk hn h2l hl heq.symm
    rw [this]
  -- otherwise both sides have exactly two parts, hence `Ω(n) = 2` and all parts are prime
  have hl2 : l.length = 2 := by
    have : 1 ≤ l.length := List.length_pos_iff.2 hl0
    omega
  have hm2 : m.length = 2 := by
    have : 1 ≤ m.length := List.length_pos_iff.2 hm0
    omega
  have hpl : ∀ a ∈ l, a.Prime := by
    refine all_prime_of_cardFactors_le_length l h2l ?_
    rw [hl, hl2]; omega
  exact collision_of_all_prime hk h2m hpl (by rw [hl, hm]) heq

/-- **The semiprime case.**  On the moduli the factoring question is about — a product of two
primes — *every* moment `k ≥ 1` separates factorisations, including the `k = 2` moment that is
ambiguous in general. -/
theorem no_collision_semiprime {k : ℕ} (hk : 1 ≤ k) {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    {l m : List ℕ} (h2l : ∀ a ∈ l, 2 ≤ a) (h2m : ∀ a ∈ m, 2 ≤ a)
    (hl : l.prod = p * q) (hm : m.prod = p * q)
    (heq : factorisationEuler k l = factorisationEuler k m) : l.Perm m := by
  have hn : 2 ≤ p * q := by
    have := hp.two_le; have := hq.two_le; nlinarith
  have hOmega : cardFactors (p * q) ≤ 2 := by
    rw [cardFactors_mul hp.pos.ne' hq.pos.ne', cardFactors_eq_one_iff_prime.2 hp,
      cardFactors_eq_one_iff_prime.2 hq]
  exact no_collision_of_cardFactors_le_two hk hn hOmega h2l h2m hl hm heq

/-! ### Lab notes: the two known collisions really do have three prime factors

`28 = 2·14 = 4·7` and `36 = 2·18 = 3·12` are the complete list of second-moment collisions
(`Novelty.GCDMomentPairInversion`).  Both moduli have `Ω ≥ 3`, and on each side of each
collision one part is composite — exactly as `no_collision_of_cardFactors_le_two`,
`collision_of_all_prime` and `collision_of_singleton` require. -/

example : factorisationEuler 2 [2, 14] = factorisationEuler 2 [4, 7] := by decide

example : factorisationEuler 2 [2, 18] = factorisationEuler 2 [3, 12] := by decide

example : cardFactors 28 = 3 := by
  rw [show (28 : ℕ) = 2 * (2 * 7) by norm_num,
    cardFactors_mul (by norm_num) (by norm_num),
    cardFactors_mul (by norm_num) (by norm_num),
    cardFactors_eq_one_iff_prime.2 (by norm_num),
    cardFactors_eq_one_iff_prime.2 (by norm_num)]

example : cardFactors 36 = 4 := by
  rw [show (36 : ℕ) = 2 * (2 * (3 * 3)) by norm_num,
    cardFactors_mul (by norm_num) (by norm_num),
    cardFactors_mul (by norm_num) (by norm_num),
    cardFactors_mul (by norm_num) (by norm_num),
    cardFactors_eq_one_iff_prime.2 (by norm_num),
    cardFactors_eq_one_iff_prime.2 (by norm_num)]

/-- The prime factorisation of `28` beats both of its two-part factorisations, and the trivial
factorisation loses to both: the bracket of cycle 3 is strict at the ends. -/
example : factorisationEuler 2 [28] < factorisationEuler 2 [2, 14] ∧
    factorisationEuler 2 [2, 14] < factorisationEuler 2 [2, 2, 7] := by decide

/-- The four factorisations of `28` and their predicted second moments: the two extremes are
attained exactly once, the middle value twice. -/
example : factorisationEuler 2 [28] = 811 ∧ factorisationEuler 2 [2, 14] = 1045 ∧
    factorisationEuler 2 [4, 7] = 1045 ∧ factorisationEuler 2 [2, 2, 7] = 1375 := by decide

end GCDMoment