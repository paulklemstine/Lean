/-
# The cyclic splitting-type channel

A self-contained, formally verified account of the *splitting-type channel* of a
cyclic field extension.

For a prime `f` the Galois group of `ℚ(ζ_f)/ℚ` is `(ℤ/f)ˣ ≅ C n` with `n = f - 1`.
Writing an unramified prime `p` as `g ^ a` for a fixed generator `g`, the residue
degree (= the order of the Frobenius `p mod f`) is

  `T(p) = ord_f(p) = n / gcd(a, n)`.

This file develops:

* a general finite (counting) Shannon-entropy framework `uEnt`, its conditional
  version `condEnt` and the mutual information `mutInfo`;
* the general structural facts: the Shannon form of `uEnt`, non-negativity, the
  `log₂ |s|` cap, and the *data-processing* inequality for deterministic
  coarsenings;
* the group-theoretic grounding: `orderOf (g ^ a) = ordType n a` for a generator
  `g` of a cyclic group of order `n`, and the exact type-count law
  `#{a : ordType n a = d} = φ d`;
* exact closed-form evaluations of the type channel and of the *type-pair
  channel* of a semiprime for `n = 2, 4, 6, 10, 12, 16`, culminating in the
  headline fact that the pair channel of `C₄` and `C₆` carries strictly more
  than one bit.
-/
import Mathlib

namespace CyclicTypeChannel

open Finset

/-! ## 1. A counting Shannon-entropy framework -/

variable {α β γ : Type*}

/-- The Shannon entropy (in bits) of the push-forward of the uniform distribution
on the finite set `s` along `g`, written as an average of fibre sizes:
`H(g) = log₂ |s| - (1/|s|) ∑_{a ∈ s} log₂ |g⁻¹(g a)|`. -/
noncomputable def uEnt [DecidableEq β] (s : Finset α) (g : α → β) : ℝ :=
  Real.logb 2 s.card - (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)) / s.card

/-- The conditional entropy `H(g | k)`: the average of the entropies of `g` on
the fibres of `k`, weighted by the size of the fibre. -/
noncomputable def condEnt [DecidableEq β] [DecidableEq γ]
    (s : Finset α) (g : α → β) (k : α → γ) : ℝ :=
  ∑ c ∈ s.image k, ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} g

/-- The mutual information `I(g ; k) = H(g) - H(g | k)`. -/
noncomputable def mutInfo [DecidableEq β] [DecidableEq γ]
    (s : Finset α) (g : α → β) (k : α → γ) : ℝ :=
  uEnt s g - condEnt s g k

section General

variable [DecidableEq β] {s : Finset α} {g : α → β}

lemma fiber_card_pos {a : α} (ha : a ∈ s) : 0 < #{x ∈ s | g x = g a} :=
  card_pos.2 ⟨a, by simp [ha]⟩

lemma sum_fiber_card (s : Finset α) (g : α → β) :
    ∑ v ∈ s.image g, #{x ∈ s | g x = v} = s.card := by
  classical
  simpa using (Finset.sum_comp (fun _ : β => (1 : ℕ)) g).symm

/-- `uEnt` really is the Shannon entropy `-∑ p log₂ p` of the push-forward
distribution. -/
theorem uEnt_eq_shannon (hs : s.Nonempty) (g : α → β) :
    uEnt s g = ∑ v ∈ s.image g,
      -((#{x ∈ s | g x = v} : ℝ) / s.card) *
        Real.logb 2 ((#{x ∈ s | g x = v} : ℝ) / s.card) := by
  classical
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hA : ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      = ∑ v ∈ s.image g, (#{x ∈ s | g x = v} : ℝ) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ) := by
    rw [Finset.sum_comp (fun v : β => Real.logb 2 (#{x ∈ s | g x = v} : ℝ)) g]
    simp [nsmul_eq_mul]
  have hcard : ∑ v ∈ s.image g, ((#{x ∈ s | g x = v} : ℝ)) = (s.card : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s g)
  have hsplit : ∀ v ∈ s.image g,
      -((#{x ∈ s | g x = v} : ℝ) / s.card) *
        Real.logb 2 ((#{x ∈ s | g x = v} : ℝ) / s.card)
      = ((#{x ∈ s | g x = v} : ℝ) / s.card) * Real.logb 2 (s.card : ℝ)
        - ((#{x ∈ s | g x = v} : ℝ) / s.card) *
            Real.logb 2 (#{x ∈ s | g x = v} : ℝ) := by
    intro v hv
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hv
    have hc : (0 : ℝ) < (#{x ∈ s | g x = g a} : ℝ) := by
      exact_mod_cast fiber_card_pos ha
    rw [Real.logb_div (ne_of_gt hc) (ne_of_gt hN)]
    ring
  have h2 : (∑ v ∈ s.image g,
        (#{x ∈ s | g x = v} : ℝ) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ)) / s.card
      = ∑ v ∈ s.image g,
        ((#{x ∈ s | g x = v} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ) := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun v _ => by ring
  rw [uEnt, hA, Finset.sum_congr rfl hsplit, Finset.sum_sub_distrib, ← Finset.sum_mul,
    ← Finset.sum_div, hcard, h2, div_self (ne_of_gt hN), one_mul]

/-- Entropy is non-negative. -/
theorem uEnt_nonneg (s : Finset α) (g : α → β) : 0 ≤ uEnt s g := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) ≤ Real.logb 2 (s.card : ℝ) := by
    intro a ha
    have hc : (0 : ℝ) < (#{x ∈ s | g x = g a} : ℝ) := by
      exact_mod_cast fiber_card_pos ha
    have : (#{x ∈ s | g x = g a} : ℝ) ≤ (s.card : ℝ) := by
      exact_mod_cast card_filter_le s _
    exact Real.logb_le_logb_of_le (by norm_num) (by positivity) this
  have hsum : (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))
      ≤ (s.card : ℝ) * Real.logb 2 (s.card : ℝ) := by
    calc (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))
        ≤ ∑ _a ∈ s, Real.logb 2 (s.card : ℝ) := Finset.sum_le_sum hterm
      _ = (s.card : ℝ) * Real.logb 2 (s.card : ℝ) := by
          simp [Finset.sum_const, nsmul_eq_mul]
  rw [uEnt, sub_nonneg, div_le_iff₀ hN]
  linarith [hsum]

/-- Entropy is capped by the log of the size of the underlying set. -/
theorem uEnt_le_logb_card (s : Finset α) (g : α → β) :
    uEnt s g ≤ Real.logb 2 s.card := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ a ∈ s, (0 : ℝ) ≤ Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) := by
    intro a ha
    have : (1 : ℝ) ≤ (#{x ∈ s | g x = g a} : ℝ) := by
      exact_mod_cast fiber_card_pos ha
    exact Real.logb_nonneg (by norm_num) this
  have : (0 : ℝ) ≤ ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) :=
    Finset.sum_nonneg hterm
  have : (0 : ℝ) ≤ (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)) / s.card :=
    div_nonneg this (le_of_lt hN)
  simp only [uEnt]
  linarith

/-- **Data processing for deterministic read-outs.** Coarsening a random variable
by post-composing with any map can only lose information: `H(h ∘ g) ≤ H(g)`. -/
theorem uEnt_comp_le [DecidableEq γ] (s : Finset α) (g : α → β) (h : β → γ) :
    uEnt s (h ∘ g) ≤ uEnt s g := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      ≤ Real.logb 2 (#{x ∈ s | (h ∘ g) x = (h ∘ g) a} : ℝ) := by
    intro a ha
    have hsub : {x ∈ s | g x = g a} ⊆ {x ∈ s | (h ∘ g) x = (h ∘ g) a} := by
      intro x hx
      simp only [mem_filter] at hx ⊢
      exact ⟨hx.1, by simp [Function.comp, hx.2]⟩
    have hc : (0 : ℝ) < (#{x ∈ s | g x = g a} : ℝ) := by
      exact_mod_cast fiber_card_pos ha
    have hle : (#{x ∈ s | g x = g a} : ℝ) ≤ (#{x ∈ s | (h ∘ g) x = (h ∘ g) a} : ℝ) := by
      exact_mod_cast card_le_card hsub
    exact Real.logb_le_logb_of_le (by norm_num) hc hle
  have hsum := Finset.sum_le_sum hterm
  have hdiv : (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)) / s.card
      ≤ (∑ a ∈ s, Real.logb 2 (#{x ∈ s | (h ∘ g) x = (h ∘ g) a} : ℝ)) / s.card := by
    gcongr
  simp only [uEnt]
  linarith

/-- A set with at most one element carries no entropy. -/
lemma uEnt_of_card_le_one (h : s.card ≤ 1) (g : α → β) : uEnt s g = 0 := by
  classical
  rcases Nat.le_one_iff_eq_zero_or_eq_one.mp h with h0 | h1
  · rw [Finset.card_eq_zero] at h0
    simp [uEnt, h0]
  · obtain ⟨a, rfl⟩ := Finset.card_eq_one.mp h1
    simp [uEnt, Finset.filter_singleton]

/-- The count-form of the entropy, the engine of every exact evaluation below:
if the multiset of fibre cardinalities of `g` is `cs`, then
`H(g) = log₂ |s| - (1/|s|) ∑_{c ∈ cs} c log₂ c`. -/
lemma sum_logb_fiber (s : Finset α) (g : α → β) :
    ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      = ∑ v ∈ s.image g, (#{x ∈ s | g x = v} : ℝ) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ) := by
  rw [Finset.sum_comp (fun v : β => Real.logb 2 (#{x ∈ s | g x = v} : ℝ)) g]
  simp [nsmul_eq_mul]

lemma uEnt_eq_countSum (s : Finset α) (g : α → β) (cs : Multiset ℕ)
    (h : (s.image g).val.map (fun v => (#{x ∈ s | g x = v} : ℕ)) = cs) :
    uEnt s g = Real.logb 2 s.card
      - (cs.map (fun c : ℕ => (c : ℝ) * Real.logb 2 (c : ℝ))).sum / s.card := by
  rw [uEnt, sum_logb_fiber, ← h, Finset.sum, Multiset.map_map]
  rfl

/-- If the conditioning variable `k` separates the points of `s`, the conditional
entropy vanishes: knowing `k` pins down everything. -/
lemma condEnt_eq_zero_of_injOn [DecidableEq γ] {k : α → γ} (g : α → β)
    (hk : Set.InjOn k s) : condEnt s g k = 0 := by
  classical
  refine Finset.sum_eq_zero fun c hc => ?_
  have hcard : (#{x ∈ s | k x = c}) ≤ 1 := by
    rw [Finset.card_le_one]
    intro x hx y hy
    simp only [mem_filter] at hx hy
    exact hk hx.1 hy.1 (by rw [hx.2, hy.2])
  rw [uEnt_of_card_le_one hcard, mul_zero]

end General

/-! ## 2. The splitting type of a cyclic Frobenius -/

/-- The **splitting type** (residue degree) attached to the exponent `a`: the order
of `g ^ a` in a cyclic group of order `n`. For `Q(ζ_f)` with `f` prime and
`n = f - 1` this is `ord_f(p) = T(p)`, the complete splitting type of `p`. -/
def ordType (n a : ℕ) : ℕ := n / Nat.gcd a n

/-- The identity residue has splitting type `1`: the prime splits completely. -/
lemma ordType_zero {n : ℕ} (hn : 0 < n) : ordType n 0 = 1 := by
  simp [ordType, Nat.div_self hn]

/-- **Thickening is free at the level of the type**: the splitting type only
depends on the residue `a mod n`, so refining the residue to a higher modulus
cannot change it. -/
lemma ordType_mod (n a : ℕ) : ordType n (a % n) = ordType n a := by
  rw [ordType, ordType, ← Nat.gcd_rec n a, Nat.gcd_comm]

lemma ordType_dvd {n : ℕ} (a : ℕ) : ordType n a ∣ n :=
  Nat.div_dvd_of_dvd (Nat.gcd_dvd_right a n)

/-- **Group-theoretic grounding.** In any finite group, the order of `g ^ a` is
given by the arithmetic function `ordType (orderOf g) a`; for a generator of a
cyclic group of order `n` this is exactly the Frobenius order used above. -/
theorem orderOf_pow_eq_ordType {G : Type*} [Group G] [Finite G] (g : G) (a : ℕ) :
    orderOf (g ^ a) = ordType (orderOf g) a := by
  rw [orderOf_pow, ordType, Nat.gcd_comm]

/-- **The exact type-count law**: for every divisor `d ∣ n` exactly `φ d` of the
`n` residues have splitting type `d`. (This is the source of the rates
`{1/4,1/4,1/2}` for `C₄`, `{1/6,1/6,1/3,1/3}` for `C₆`, and so on.) -/
theorem card_ordType_eq_totient {n d : ℕ} (hn : 0 < n) (hd : d ∣ n) :
    #{a ∈ range n | ordType n a = d} = Nat.totient d := by
  obtain ⟨k, hk⟩ := hd
  have hd0 : 0 < d := Nat.pos_of_ne_zero (by rintro rfl; simp [hk] at hn)
  have hk0 : 0 < k := Nat.pos_of_ne_zero (by rintro rfl; simp [hk] at hn)
  have key : ∀ a, a < n → ordType n a = d → Nat.gcd a n = k := by
    intro a _ hgd
    have h1 : Nat.gcd a n ∣ n := Nat.gcd_dvd_right _ _
    have h2 : Nat.gcd a n * d = n := by rw [← hgd, ordType]; exact Nat.mul_div_cancel' h1
    have : d * Nat.gcd a n = d * k := by rw [Nat.mul_comm] at h2; omega
    exact Nat.eq_of_mul_eq_mul_left hd0 this
  rw [Nat.totient]
  refine (Finset.card_bij' (fun m _ => m * k) (fun a _ => a / k) ?_ ?_ ?_ ?_).symm
  · intro m hm
    simp only [mem_filter, mem_range] at hm ⊢
    have hco : Nat.gcd m d = 1 := Nat.Coprime.symm hm.2
    refine ⟨by calc m * k < d * k := (Nat.mul_lt_mul_right hk0).2 hm.1
              _ = n := hk.symm, ?_⟩
    have hg : Nat.gcd (m * k) n = k := by
      rw [hk, Nat.mul_comm m k, Nat.mul_comm d k, Nat.gcd_mul_left, hco, Nat.mul_one]
    rw [ordType, hg, hk, Nat.mul_div_cancel _ hk0]
  · intro a ha
    simp only [mem_filter, mem_range] at ha ⊢
    have hg : Nat.gcd a n = k := key a ha.1 ha.2
    have hka : k ∣ a := hg ▸ Nat.gcd_dvd_left a n
    obtain ⟨m, rfl⟩ := hka
    rw [Nat.mul_div_cancel_left _ hk0]
    have hco : Nat.gcd m d = 1 := by
      rw [hk, Nat.mul_comm d k, Nat.gcd_mul_left] at hg
      exact Nat.eq_of_mul_eq_mul_left hk0 (by rw [Nat.mul_one]; exact hg)
    refine ⟨?_, Nat.Coprime.symm hco⟩
    have hlt : k * m < d * k := hk ▸ ha.1
    nlinarith [hlt]
  · intro m _
    exact Nat.mul_div_cancel _ hk0
  · intro a ha
    simp only [mem_filter, mem_range] at ha
    have hg : Nat.gcd a n = k := key a ha.1 ha.2
    exact Nat.div_mul_cancel (hg ▸ Nat.gcd_dvd_left a n)

/-! ## 3. The type channel and the semiprime type-pair channel -/

/-- The residues (exponents) of the two prime factors of a semiprime. -/
def box (n : ℕ) : Finset (ℕ × ℕ) := range n ×ˢ range n

/-- The **unordered** splitting-type pair `{T(p), T(q)}` of a semiprime `N = p q`. -/
def typePair (n : ℕ) (p : ℕ × ℕ) : ℕ × ℕ :=
  (min (ordType n p.1) (ordType n p.2), max (ordType n p.1) (ordType n p.2))

/-- The residue of the semiprime `N = p q` itself: exponents add. -/
def prodRes (n : ℕ) (p : ℕ × ℕ) : ℕ := (p.1 + p.2) % n

/-- The root-count read-out of a splitting type: the number of roots of the
cyclotomic polynomial mod `p`, i.e. `n` if `p` splits completely and `0`
otherwise. -/
def rootCount (n T : ℕ) : ℕ := if T = 1 then n else 0

/-- The `s`-projection of a type pair: how many of the two primes split
completely. -/
def sProj (t : ℕ × ℕ) : ℕ := (if t.1 = 1 then 1 else 0) + (if t.2 = 1 then 1 else 0)

/-- Entropy of the splitting type of a single prime. -/
noncomputable def typeEntropy (n : ℕ) : ℝ := uEnt (range n) (ordType n)

/-- Entropy of the unordered type pair of a semiprime. -/
noncomputable def pairEntropy (n : ℕ) : ℝ := uEnt (box n) (typePair n)

/-- Entropy of the unordered type pair given the residue of the semiprime. -/
noncomputable def condPairEntropy (n : ℕ) : ℝ := condEnt (box n) (typePair n) (prodRes n)

/-- The **type-pair channel** `I({T(p),T(q)} ; N mod f)`. -/
noncomputable def Ipair (n : ℕ) : ℝ := mutInfo (box n) (typePair n) (prodRes n)

/-- The split-count (`s`-projection) channel `I(s ; N mod f)`. -/
noncomputable def Isplit (n : ℕ) : ℝ := mutInfo (box n) (sProj ∘ typePair n) (prodRes n)

lemma Ipair_eq (n : ℕ) : Ipair n = pairEntropy n - condPairEntropy n := rfl

lemma Isplit_eq (n : ℕ) :
    Isplit n = uEnt (box n) (sProj ∘ typePair n)
      - condEnt (box n) (sProj ∘ typePair n) (prodRes n) := rfl

/-- **The which-factor wall.** The type pair is a symmetric function of the two
primes, so it cannot distinguish `p` from `q`. -/
theorem typePair_symm (n : ℕ) (a b : ℕ) : typePair n (a, b) = typePair n (b, a) := by
  simp [typePair, min_comm, max_comm]

/-- The residue of the product is symmetric too. -/
theorem prodRes_symm (n : ℕ) (a b : ℕ) : prodRes n (a, b) = prodRes n (b, a) := by
  simp [prodRes, Nat.add_comm]

/-- **The residue determines the type exactly**: `I(p mod f ; T) = H(T)`. -/
theorem mutInfo_residue_type (n : ℕ) : mutInfo (range n) (ordType n) id = typeEntropy n := by
  rw [mutInfo, condEnt_eq_zero_of_injOn _ (Set.injOn_id _), sub_zero, typeEntropy]

/-- **Thickening zero.** Refining the residue `p mod f` to any finer invariant
`w` (for instance `p mod f²`) leaves the type channel unchanged: it is already
exactly `H(T)`. -/
theorem thickening_zero {γ : Type*} [DecidableEq γ] (n : ℕ) (w : ℕ → γ)
    (hw : Set.InjOn w (range n)) : mutInfo (range n) (ordType n) w = typeEntropy n := by
  rw [mutInfo, condEnt_eq_zero_of_injOn _ hw, sub_zero, typeEntropy]

/-- **The root-count read-out is a coarsening of the type**, hence (data
processing) can never carry more information than the type itself. -/
theorem rootCount_entropy_le (n : ℕ) :
    uEnt (range n) (rootCount n ∘ ordType n) ≤ typeEntropy n :=
  uEnt_comp_le _ _ _

/-- **The `s`-projection is a coarsening of the type pair.** -/
theorem sProj_entropy_le (n : ℕ) :
    uEnt (box n) (sProj ∘ typePair n) ≤ pairEntropy n :=
  uEnt_comp_le _ _ _

/-- Conditioning does not disturb the coarsening order. -/
theorem condEnt_comp_le {β' γ : Type*} [DecidableEq β] [DecidableEq β'] [DecidableEq γ]
    (s : Finset α) (g : α → β) (h : β → β') (k : α → γ) :
    condEnt s (h ∘ g) k ≤ condEnt s g k := by
  refine Finset.sum_le_sum fun c _ => ?_
  have := uEnt_comp_le {x ∈ s | k x = c} g h
  have hw : (0 : ℝ) ≤ (#{x ∈ s | k x = c} : ℝ) / s.card := by positivity
  exact mul_le_mul_of_nonneg_left this hw

/-! ## 4. Base-two logarithms of the numerals that occur -/

lemma lb_pow (k : ℕ) : Real.logb 2 ((2 : ℝ) ^ k) = k := by
  rw [Real.logb_pow]; simp

lemma lb_4 : Real.logb 2 (4 : ℝ) = 2 := by
  rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_8 : Real.logb 2 (8 : ℝ) = 3 := by
  rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_16 : Real.logb 2 (16 : ℝ) = 4 := by
  rw [show (16 : ℝ) = 2 ^ (4 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_32 : Real.logb 2 (32 : ℝ) = 5 := by
  rw [show (32 : ℝ) = 2 ^ (5 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_64 : Real.logb 2 (64 : ℝ) = 6 := by
  rw [show (64 : ℝ) = 2 ^ (6 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_256 : Real.logb 2 (256 : ℝ) = 8 := by
  rw [show (256 : ℝ) = 2 ^ (8 : ℕ) by norm_num, lb_pow]; norm_num

lemma lb_6 : Real.logb 2 (6 : ℝ) = 1 + Real.logb 2 3 := by
  rw [show (6 : ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num)]
  simp

lemma lb_12 : Real.logb 2 (12 : ℝ) = 2 + Real.logb 2 3 := by
  rw [show (12 : ℝ) = 4 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4]

lemma lb_36 : Real.logb 2 (36 : ℝ) = 2 + 2 * Real.logb 2 3 := by
  rw [show (36 : ℝ) = 4 * (3 * 3) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), lb_4]
  ring

lemma lb_144 : Real.logb 2 (144 : ℝ) = 4 + 2 * Real.logb 2 3 := by
  rw [show (144 : ℝ) = 16 * (3 * 3) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), lb_16]
  ring

lemma lb_9 : Real.logb 2 (9 : ℝ) = 2 * Real.logb 2 3 := by
  rw [show (9 : ℝ) = 3 ^ (2 : ℕ) by norm_num, Real.logb_pow]
  norm_num

lemma lb_25 : Real.logb 2 (25 : ℝ) = 2 * Real.logb 2 5 := by
  rw [show (25 : ℝ) = 5 ^ (2 : ℕ) by norm_num, Real.logb_pow]
  norm_num

lemma lb_81 : Real.logb 2 (81 : ℝ) = 4 * Real.logb 2 3 := by
  rw [show (81 : ℝ) = 3 ^ (4 : ℕ) by norm_num, Real.logb_pow]
  norm_num

lemma lb_15 : Real.logb 2 (15 : ℝ) = Real.logb 2 3 + Real.logb 2 5 := by
  rw [show (15 : ℝ) = 3 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num)]

lemma lb_24 : Real.logb 2 (24 : ℝ) = 3 + Real.logb 2 3 := by
  rw [show (24 : ℝ) = 8 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_8]

lemma lb_225 : Real.logb 2 (225 : ℝ) = 2 * Real.logb 2 3 + 2 * Real.logb 2 5 := by
  rw [show (225 : ℝ) = 9 * 25 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_9,
    lb_25]

lemma lb_10 : Real.logb 2 (10 : ℝ) = 1 + Real.logb 2 5 := by
  rw [show (10 : ℝ) = 2 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num)]
  simp

lemma lb_100 : Real.logb 2 (100 : ℝ) = 2 + 2 * Real.logb 2 5 := by
  rw [show (100 : ℝ) = 4 * (5 * 5) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), lb_4]
  ring

/-! ## 5. Faithfulness of the exponent model, and the exact `φ`-law for `H(T)` -/

/-- The splitting types occurring in the `C n` channel are exactly the divisors of `n`. -/
theorem image_ordType (n : ℕ) (hn : 0 < n) : (range n).image (ordType n) = n.divisors := by
  ext d
  simp only [mem_image, mem_range, Nat.mem_divisors]
  constructor
  · rintro ⟨a, _, rfl⟩
    exact ⟨ordType_dvd a, hn.ne'⟩
  · rintro ⟨hd, -⟩
    refine ⟨(n / d) % n, Nat.mod_lt _ hn, ?_⟩
    rw [ordType_mod, ordType, Nat.gcd_eq_left (Nat.div_dvd_of_dvd hd),
      Nat.div_div_self hd hn.ne']

/-- **The exact `φ`-law for the type channel.** For every `n > 0`,
`H(T) = ∑_{d ∣ n} (φ(d)/n) · log₂ (n / φ(d))`;
the splitting type `d` occurs with rate `φ(d)/n`. -/
theorem typeEntropy_formula (n : ℕ) (hn : 0 < n) :
    typeEntropy n
      = ∑ d ∈ n.divisors, ((Nat.totient d : ℝ) / n) * Real.logb 2 ((n : ℝ) / Nat.totient d) := by
  have hne : (range n).Nonempty := by
    exact ⟨0, mem_range.2 hn⟩
  rw [typeEntropy, uEnt_eq_shannon hne, image_ordType n hn]
  refine Finset.sum_congr rfl fun d hd => ?_
  have hd' : d ∣ n := (Nat.mem_divisors.1 hd).1
  have hcard : (#{x ∈ range n | ordType n x = d}) = Nat.totient d :=
    card_ordType_eq_totient hn hd'
  have hphi : (0 : ℝ) < (Nat.totient d : ℝ) := by
    have : 0 < Nat.totient d := Nat.totient_pos.2 (Nat.pos_of_dvd_of_pos hd' hn)
    exact_mod_cast this
  have hN : (0 : ℝ) < (#(range n) : ℝ) := by
    simpa using (by exact_mod_cast hn : (0 : ℝ) < (n : ℝ))
  rw [hcard, card_range, Real.logb_div (ne_of_gt hphi) (ne_of_gt (by exact_mod_cast hn)),
    Real.logb_div (by exact_mod_cast hn.ne') (ne_of_gt hphi)]
  ring

/-- **The exponent model is faithful.** For a prime `f`, every unit of `ZMod f` is
a power `g ^ a` of a fixed generator with `a < f - 1`, and its Frobenius order —
the residue degree of the corresponding prime in `Q(ζ_f)` — is exactly
`ordType (f - 1) a`. -/
theorem exists_generator_ordType (f : ℕ) [hf : Fact f.Prime] :
    ∃ g : (ZMod f)ˣ, orderOf g = f - 1 ∧
      ∀ u : (ZMod f)ˣ, ∃ a < f - 1, u = g ^ a ∧ orderOf u = ordType (f - 1) a := by
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := (ZMod f)ˣ)
  have hcard : Nat.card ((ZMod f)ˣ) = f - 1 := by
    have : Fintype.card ((ZMod f)ˣ) = f - 1 := by
      rw [ZMod.card_units_eq_totient, Nat.totient_prime hf.out]
    simpa [Nat.card_eq_fintype_card] using this
  have hord : orderOf g = f - 1 := by
    rw [orderOf_eq_card_of_forall_mem_zpowers hg, hcard]
  have hpos : 0 < f - 1 := by
    have := hf.out.two_le
    omega
  refine ⟨g, hord, fun u => ?_⟩
  have hk' : ∃ k : ℕ, g ^ k = u := by
    have := (mem_powers_iff_mem_zpowers (x := g) (y := u)).2 (hg u)
    exact this
  obtain ⟨k, rfl⟩ := hk'
  refine ⟨k % (f - 1), Nat.mod_lt _ hpos, ?_, ?_⟩
  · rw [← hord, pow_mod_orderOf]
  · rw [orderOf_pow_eq_ordType, hord, ← hord, ordType_mod]

/-- `log₂ 3 > 3/2`, i.e. `9 > 8`. -/
lemma lb_three_gt : (3 : ℝ) / 2 < Real.logb 2 3 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log 8 < Real.log 9 := Real.log_lt_log (by norm_num) (by norm_num)
  rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, show (9 : ℝ) = 3 ^ (2 : ℕ) by norm_num,
    Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 5 > 58/25`, i.e. `5 ^ 25 > 2 ^ 58`. -/
lemma lb_five_gt : (58 : ℝ) / 25 < Real.logb 2 5 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (58 : ℕ)) < Real.log ((5 : ℝ) ^ (25 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 3 < 8/5`, i.e. `3 ^ 5 = 243 < 256 = 2 ^ 8`. -/
lemma lb_three_lt : Real.logb 2 3 < (8 : ℝ) / 5 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((3 : ℝ) ^ (5 : ℕ)) < Real.log ((2 : ℝ) ^ (8 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 5 < 7/3`, i.e. `5 ^ 3 = 125 < 128 = 2 ^ 7`. -/
lemma lb_five_lt : Real.logb 2 5 < (7 : ℝ) / 3 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((5 : ℝ) ^ (3 : ℕ)) < Real.log ((2 : ℝ) ^ (7 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

end CyclicTypeChannel